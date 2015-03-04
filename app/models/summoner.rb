class Summoner < ActiveRecord::Base
  has_many :summoner_stats_lists
  has_many :stats_rankeds, through: :summoner_stats_lists

  serialize :league
  serialize :stats_summary
end
