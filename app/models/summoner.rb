class Summoner < ActiveRecord::Base
  serialize :league
  serialize :stats_summary
end
