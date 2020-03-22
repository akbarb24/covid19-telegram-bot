class CreateCases < ActiveRecord::Migration[5.1]
  def change
    create_table :cases, force: true do |t|
      t.integer "prov_code"
      t.string "prov_name"
      t.string "last_update"
      t.integer "infected"
      t.integer "recovered"
      t.integer "active"
      t.integer "death"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end