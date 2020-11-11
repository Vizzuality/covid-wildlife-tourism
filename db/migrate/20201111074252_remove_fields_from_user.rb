class RemoveFieldsFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :app_uuid
    remove_column :users, :last_post
    remove_column :users, :store_owner_code
    remove_column :users, :badges_won
    remove_column :users, :badges_tracker
  end
end
