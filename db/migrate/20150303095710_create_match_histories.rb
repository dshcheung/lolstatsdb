class CreateMatchHistories < ActiveRecord::Migration
  def change
    create_table :match_histories do |t|
      t.integer :summonerId
      t.integer :matchId
      t.integer :match_creation, limit: 8
      t.string :region
      t.string :queue
      t.integer :championId
      t.string :champion_name
      t.string :champion_key
      t.string :winner
      t.string :role
      t.string :lane

      t.timestamps
    end
  end
end
