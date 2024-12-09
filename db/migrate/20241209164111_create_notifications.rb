class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.references :story, null: false, foreign_key: true
      t.string :action, null: false
      t.datetime :read_at

      t.timestamps
    end
  end
end
