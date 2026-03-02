class QuestionnaireSubmission
  class Error < StandardError; end

  def self.call(*args)
    new(*args).call
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

    activity = Activity.new(
      lead: @lead,
      domain: @questionnaire_taxbranch.header_domain,
      taxbranch: @questionnaire_taxbranch,
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
  end

  private

  def validate_inputs!
    raise Error, "lead is required" if @lead.blank?
    raise Error, "questionnaire_taxbranch is required" if @questionnaire_taxbranch.blank?
    raise Error, "taxbranch must be questionnaire root" unless @questionnaire_taxbranch.questionnaire_root?
  end

  def default_description
    "Questionnaire submission: #{@questionnaire_taxbranch.slug_label}"
  end

  def build_payload(score_result)
    {
      "description" => @description.presence || default_description,
      "questionnaire_source" => @questionnaire_taxbranch.questionnaire_source.presence,
      "questionnaire_version" => @questionnaire_taxbranch.questionnaire_version.presence,
      "answers" => normalize_answers(@answers),
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
end
