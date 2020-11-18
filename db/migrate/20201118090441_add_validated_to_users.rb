class AddValidatedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :validated, :boolean, index: true, default: false
  end
end
