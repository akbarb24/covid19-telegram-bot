class RenameColumnUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :uid, :userid
  end
end