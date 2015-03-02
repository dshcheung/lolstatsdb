class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues do |t|
      t.string :region
      t.string :queue
      t.string :name
      t.string :tier
      t.string :division
      t.integer :summonerId
      t.integer :league_points
      t.text :entry

      t.timestamps
    end
  end
end
