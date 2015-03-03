class CreateMatchHistories < ActiveRecord::Migration
  def change
    create_table :match_histories do |t|
      t.integer :summonerId
      t.integer :matchId
      t.integer :match_creation
      t.string :region
      t.string :queue
      t.integer :championId
      t.string :winner
      t.string :role
      t.string :lane
      t.text :match

      t.timestamps
    end
  end
end
