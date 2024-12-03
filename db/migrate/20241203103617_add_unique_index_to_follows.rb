class AddUniqueIndexToFollows < ActiveRecord::Migration[7.1]
  def change
    add_index :follows, [:follower_id, :followee_id], unique: true, name: 'index_follows_on_follower_and_followee'
  end
end
