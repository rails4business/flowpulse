class QuestionnaireScoring
  def self.call(questionnaire_taxbranch:, answers:)
    new(questionnaire_taxbranch: questionnaire_taxbranch, answers: answers).call
  end

  def initialize(questionnaire_taxbranch:, answers:)
    @questionnaire_taxbranch = questionnaire_taxbranch
    @answers = normalize_answers(answers)
  end

  def call
    config = @questionnaire_taxbranch.scoring_config
    return nil unless config["enabled"] == true

    question_nodes = @questionnaire_taxbranch.questionnaire_questions.to_a
    question_by_id = question_nodes.index_by(&:id)
    question_by_slug = question_nodes.index_by(&:slug)
    definition_questions = Array(@questionnaire_taxbranch.questionnaire_definition["questions"])
    definition_by_code = definition_questions.index_by { |q| q.is_a?(Hash) ? q["code"].to_s : nil }.compact
    question_rules = Array(config["questions"])

    scored_rows = @answers.filter_map do |answer|
      question_id = answer["question_taxbranch_id"].to_i
      question_slug = answer["question_slug"].to_s.presence
      question_code = answer["question_code"].to_s.presence
      question = question_by_id[question_id] || (question_slug.present? ? question_by_slug[question_slug] : nil)
      definition_question = question_code.present? ? definition_by_code[question_code] : nil

      value_num = numeric_value(answer["value"])
      next if value_num.nil?

      rule = find_question_rule(question_rules, question, question_id, question_slug, question_code)
      min_value = (rule && rule["min"]) || (definition_question && definition_question["min"]) || 0
      max_value = (rule && rule["max"]) || (definition_question && definition_question["max"]) || 3
      weight = (rule && rule["weight"]) || 1
      clamped = value_num.clamp(min_value.to_f, max_value.to_f)
      weighted = clamped * weight.to_f

      {
        "question_taxbranch_id" => question_id,
        "question_slug" => question&.slug || question_slug,
        "question_code" => question_code,
        "raw_value" => value_num,
        "value" => clamped,
        "weight" => weight.to_f,
        "score" => weighted
      }
    end

    total = scored_rows.sum { |row| row["score"].to_f }
    max_total = configured_or_derived_max_total(config, question_rules, scored_rows, definition_questions)
    level = resolve_level(total, config["levels"])

    {
      "total" => total.round(2),
      "max_total" => max_total.round(2),
      "percentage" => max_total.positive? ? ((total / max_total) * 100.0).round(2) : 0.0,
      "level_code" => level && level["code"],
      "level_label" => level && level["label"],
      "interpretation" => level && level["interpretation"],
      "recommendation" => level && level["recommendation"],
      "scored_answers" => scored_rows
    }
  end

  private

  def normalize_answers(answers)
    case answers
    when Array
      answers.filter_map do |entry|
        next unless entry.respond_to?(:to_h)

        entry.to_h.stringify_keys
      end
    when Hash
      answers.map do |question_ref, payload|
        if payload.is_a?(Hash)
          {
            "question_taxbranch_id" => question_ref.to_s.match?(/\A\d+\z/) ? question_ref.to_i : nil,
            "question_code" => payload[:question_code].presence || payload["question_code"].presence || question_ref.to_s,
            "question_slug" => payload[:question_slug].presence || payload["question_slug"].presence,
            "value" => payload[:value].presence || payload["value"]
          }
        else
          {
            "question_taxbranch_id" => question_ref.to_s.match?(/\A\d+\z/) ? question_ref.to_i : nil,
            "question_code" => question_ref.to_s,
            "value" => payload
          }
        end
      end
    else
      []
    end
  end

  def numeric_value(value)
    return value.to_f if value.is_a?(Numeric)

    str = value.to_s.strip
    return nil if str.blank?
    return nil unless str.match?(/\A-?\d+(\.\d+)?\z/)

    str.to_f
  end

  def find_question_rule(rules, question, question_id, question_slug, question_code)
    rules.find do |rule|
      next false unless rule.is_a?(Hash)

      rid = rule["question_taxbranch_id"].to_i if rule["question_taxbranch_id"].present?
      rslug = rule["question_slug"].to_s
      rcode = rule["question_code"].to_s
      (rid.present? && rid == question_id.to_i) ||
        (question.present? && rslug.present? && rslug == question.slug) ||
        (question_slug.present? && rslug.present? && rslug == question_slug) ||
        (question_code.present? && rcode.present? && rcode == question_code)
    end
  end

  def configured_or_derived_max_total(config, question_rules, scored_rows, definition_questions)
    explicit = config["max_total"]
    return explicit.to_f if explicit.present?

    if question_rules.any?
      question_rules.sum do |rule|
        max_value = rule.is_a?(Hash) ? (rule["max"] || 3).to_f : 3.0
        weight = rule.is_a?(Hash) ? (rule["weight"] || 1).to_f : 1.0
        max_value * weight
      end
    elsif definition_questions.any?
      definition_questions.sum do |row|
        next 3.0 unless row.is_a?(Hash)

        (row["max"] || 3).to_f
      end
    else
      scored_rows.size * 3.0
    end
  end

  def resolve_level(total, levels)
    Array(levels).find do |level|
      next false unless level.is_a?(Hash)

      min = (level["min"] || 0).to_f
      max = (level["max"] || 0).to_f
      total >= min && total <= max
    end
  end
end
