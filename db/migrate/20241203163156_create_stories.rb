class CreateStories < ActiveRecord::Migration[7.1]
  def change
    create_table :stories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :media
      t.string :media_url
      t.text :text
      t.datetime :expires_at

      t.timestamps
    end
  end
end
