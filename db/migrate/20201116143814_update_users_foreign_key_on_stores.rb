class UpdateUsersForeignKeyOnStores < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :stores, :users, column: :created_by_id
    remove_foreign_key :stores, :users, column: :updated_by_id

    add_foreign_key :stores, :users, column: :created_by_id, on_delete: :nullify
    add_foreign_key :stores, :users, column: :updated_by_id, on_delete: :nullify
  end
end
