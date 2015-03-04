class CreateSummonerStatsLists < ActiveRecord::Migration
  def change
    create_table :summoner_stats_lists do |t|
      t.integer :stats_ranked_id
      t.integer :summoner_id
      t.timestamps
    end
  end
end
