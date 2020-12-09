class SwitchValidatedDefaultInUsers < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :validated, true
  end
end
