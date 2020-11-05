class ChangeStoreAttributes < ActiveRecord::Migration[6.0]
  def change
    remove_column :stores, :group, :string
    remove_column :stores, :capacity, :string
    remove_column :stores, :open, :boolean
    remove_column :stores, :from_osm, :boolean
    remove_column :stores, :original_id, :string
    remove_column :stores, :source, :string
    remove_column :stores, :make_phone_calls, :boolean
    remove_column :stores, :phone_call_interval, :integer
    remove_column :stores, :store_type, :integer
    remove_column :stores, :details, :text
    remove_column :stores, :reason_to_delete, :text

    add_column :stores, :website, :string, index: true
    add_column :stores, :type, :string, index: true, null: false
    add_column :stores, :population_size, :integer
    add_column :stores, :user_is_owner, :boolean, null: false, default: false
    add_column :stores, :owner_details, :text
    add_column :stores, :farming_reliance, :integer
    add_column :stores, :wildlife_reliance, :integer
    add_column :stores, :enterprise_type, :string, array: true, default: [], index: true
    add_column :stores, :ownership, :string
    add_column :stores, :reason_to_change, :text

    add_reference :stores, :related_store, foreign_key: { to_table: :stores }, index: true
  end
end
