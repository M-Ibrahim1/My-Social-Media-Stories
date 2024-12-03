class RemoveProfilePictureFromUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :profile_picture
  end
end
