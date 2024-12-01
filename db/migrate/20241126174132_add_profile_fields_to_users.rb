class AddProfileFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :name, :string
    add_column :users, :bio, :text
    add_column :users, :profile_picture, :string
    add_column :users, :gender, :string
  end
end
