class AddIndexAndConstraintsToNotifications < ActiveRecord::Migration[7.1]
  def change
    change_column_null :notifications, :recipient_id, false
    change_column_null :notifications, :actor_id, false
    change_column_null :notifications, :action, false

    unless index_exists?(:notifications, :recipient_id)
      add_index :notifications, :recipient_id
    end

    unless index_exists?(:notifications, :actor_id)
      add_index :notifications, :actor_id
    end

    unless index_exists?(:notifications, [:recipient_id, :read_at])
      add_index :notifications, [:recipient_id, :read_at]
    end
  end
end
