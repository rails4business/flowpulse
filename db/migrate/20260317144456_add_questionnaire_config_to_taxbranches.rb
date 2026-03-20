class AddQuestionnaireConfigToTaxbranches < ActiveRecord::Migration[8.1]
  def change
    add_column :taxbranches, :questionnaire_config, :jsonb
  end
end
