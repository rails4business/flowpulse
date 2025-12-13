class AddDiagrammermaidToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :mermaid, :text
  end
end
