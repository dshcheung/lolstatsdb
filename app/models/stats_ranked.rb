class StatsRanked < ActiveRecord::Base
  has_many :summoner_stats_lists
  has_many :summoner, through: :summoner_stats_lists
end
