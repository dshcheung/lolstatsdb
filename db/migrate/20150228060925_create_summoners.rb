class CreateSummoners < ActiveRecord::Migration
  def change
    create_table :summoners do |t|
      t.string :region
      t.string :name
      t.integer :summonerId
      t.integer :profileIconId
      t.integer :level
      t.text :league
      t.text :stats_summary
      t.timestamps
    end
  end
end
