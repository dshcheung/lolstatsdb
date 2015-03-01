class SummonerStatsList < ActiveRecord::Base
  belongs_to :summoner
  belongs_to :stats_ranked
end
