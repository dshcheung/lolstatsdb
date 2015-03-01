class CreateChampions < ActiveRecord::Migration
  def change
    create_table :champions do |t|
      t.integer :championId
      t.string :title
      t.string :name
      t.string :name_key
      t.text :image
      t.string :region

      t.timestamps
    end
  end
end
