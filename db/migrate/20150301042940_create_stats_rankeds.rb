class CreateStatsRankeds < ActiveRecord::Migration
  def change
    create_table :stats_rankeds do |t|
      t.integer :championId
      t.string :champion_name
      t.string :champion_name_key
      t.integer :penta_kills
      t.integer :quadra_kills
      t.integer :triple_kills
      t.integer :double_kills
      t.integer :total_kills
      t.float :average_kills
      t.integer :total_assists
      t.float :average_assists
      t.integer :total_deaths
      t.float :average_deaths
      t.integer :total_minions
      t.integer :average_minions
      t.integer :total_gold
      t.integer :average_gold
      t.integer :total_games
      t.integer :total_wins
      t.integer :total_losses
      t.float :win_rate
      t.timestamps
    end
  end
end
