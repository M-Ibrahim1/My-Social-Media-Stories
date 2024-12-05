class CreateViews < ActiveRecord::Migration[7.1]
  def change
    create_table :views do |t|
      t.references :story, null: false, foreign_key: true
      t.references :viewer, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
