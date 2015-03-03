class CreateMatchDetails < ActiveRecord::Migration
  def change
    create_table :match_details do |t|
      t.integer :matchId
      t.integer :region
      t.text :participants
      t.text :participant_identities

      t.timestamps
    end
  end
end
