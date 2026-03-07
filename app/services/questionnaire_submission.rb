class QuestionnaireSubmission
  class Error < StandardError; end

  def self.call(**kwargs)
    new(**kwargs).call
  end

  def initialize(lead:, questionnaire_taxbranch:, answers:, occurred_at: Time.current, description: nil, source_ref: nil)
    @lead = lead
    @questionnaire_taxbranch = questionnaire_taxbranch
    @answers = answers
    @occurred_at = occurred_at
    @description = description
    @source_ref = source_ref
  end

  def call
    validate_inputs!

    score_result = QuestionnaireScoring.call(
      questionnaire_taxbranch: @questionnaire_taxbranch,
      answers: @answers
    )

    activity = find_or_build_open_activity
    activity.assign_attributes(
      domain: @questionnaire_taxbranch.header_domain,
      kind: :questionnaire_submission,
      status: :recorded,
      occurred_at: @occurred_at,
      source: "questionnaire",
      source_ref: @source_ref.presence || @questionnaire_taxbranch.slug,
      level_code: score_result && score_result["level_code"],
      score_total: score_result && score_result["total"],
      score_max: score_result && score_result["max_total"],
      payload: build_payload(score_result)
    )
    activity.save!
    activity
  rescue ActiveRecord::RecordNotUnique
    activity = @lead.activities
                    .where(taxbranch_id: @questionnaire_taxbranch.id, status: %w[recorded reviewed])
                    .order(occurred_at: :desc, id: :desc)
                    .first
    raise if activity.blank?

    activity.update!(
      kind: :questionnaire_submission,
      occurred_at: @occurred_at,
      source: "questionnaire",
      source_ref: @source_ref.presence || @questionnaire_taxbranch.slug,
      level_code: score_result && score_result["level_code"],
      score_total: score_result && score_result["total"],
      score_max: score_result && score_result["max_total"],
      payload: build_payload(score_result)
    )
    activity
  end

  private

  def find_or_build_open_activity
    @lead.activities
         .where(taxbranch_id: @questionnaire_taxbranch.id, status: %w[recorded reviewed])
         .order(occurred_at: :desc, id: :desc)
         .first || Activity.new(
           lead: @lead,
           taxbranch: @questionnaire_taxbranch
         )
  end

  def validate_inputs!
    raise Error, "lead is required" if @lead.blank?
    raise Error, "questionnaire_taxbranch is required" if @questionnaire_taxbranch.blank?
    raise Error, "taxbranch must be questionnaire root" unless @questionnaire_taxbranch.questionnaire_root?
  end

  def default_description
    "Questionnaire submission: #{@questionnaire_taxbranch.slug_label}"
  end

  def build_payload(score_result)
    normalized_answers = normalize_answers(@answers)
    snapshot = questionnaire_snapshot
    {
      "description" => @description.presence || default_description,
      "questionnaire_source" => @questionnaire_taxbranch.questionnaire_source.presence,
      "questionnaire_version" => @questionnaire_taxbranch.questionnaire_version.presence,
      "answers" => normalized_answers,
      "answers_detailed" => detailed_answers(normalized_answers, snapshot),
      "questionnaire_snapshot" => snapshot,
      "score_result" => score_result
    }.compact
  end

  def normalize_answers(value)
    case value
    when ActionController::Parameters
      value.to_unsafe_h
    when Hash
      value
    else
      Array(value)
    end
  end

  def questionnaire_snapshot
    definition = @questionnaire_taxbranch.questionnaire_definition
    raw_questions = hash_value(definition, "questions") || hash_value(definition, "domande") || []
    questions = Array(raw_questions).sort_by { |q| hash_value(q, "position").to_i }

    {
      "captured_at" => Time.current.iso8601,
      "slug" => hash_value(definition, "slug").presence || @questionnaire_taxbranch.slug,
      "title" => hash_value(definition, "title").presence || @questionnaire_taxbranch.slug_label,
      "version" => hash_value(definition, "version").presence || @questionnaire_taxbranch.questionnaire_version,
      "questions" => questions.map do |q|
        {
          "code" => hash_value(q, "code").to_s,
          "position" => hash_value(q, "position"),
          "movement" => hash_value(q, "movement").to_s,
          "kind" => hash_value(q, "kind").to_s,
          "options" => normalize_options(hash_value(q, "options"))
        }
      end
    }
  end

  def detailed_answers(answers_hash, snapshot)
    question_index = Array(snapshot["questions"]).index_by { |q| q["code"].to_s }
    answers_hash.to_h.map do |code, raw_value|
      value = raw_value.is_a?(Array) ? raw_value.map(&:to_s) : raw_value.to_s
      question = question_index[code.to_s] || {}
      {
        "code" => code.to_s,
        "question" => question["movement"].to_s,
        "kind" => question["kind"].to_s,
        "value" => value,
        "label" => answer_label_for(question, value)
      }
    end
  end

  def normalize_options(raw_options)
    Array(raw_options).map do |opt|
      if opt.is_a?(Hash)
        value = hash_value(opt, "value").to_s
        label = hash_value(opt, "label").to_s
        { "value" => value, "label" => label.presence || value }
      else
        text = opt.to_s
        { "value" => text, "label" => text }
      end
    end
  end

  def answer_label_for(question, value)
    options = Array(question["options"])
    return value if options.blank?
    return value.map { |v| answer_label_for(question, v) } if value.is_a?(Array)

    found = options.find { |o| o["value"].to_s == value.to_s }
    found.present? ? found["label"].to_s : value.to_s
  end

  def hash_value(data, key)
    return nil unless data.is_a?(Hash)

    data[key] || data[key.to_s] || data[key.to_sym]
  end
end
