class RemoveColumnCases < ActiveRecord::Migration[5.1]
  def change
    remove_column :cases, :prov_name
    remove_column :cases, :prov_code
    remove_column :cases, :last_update
  end
end