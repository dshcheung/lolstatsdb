class CreateDetailMatches < ActiveRecord::Migration
  def change
    create_table :detail_matches do |t|

      t.timestamps
    end
  end
end
