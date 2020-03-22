class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, force: true do |t|
      t.integer :uid
      t.boolean :is_subscribe
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
