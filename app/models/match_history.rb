class MatchHistory < ActiveRecord::Base
  serialize :match

  validates_uniqueness_of :matchId, scope: [:summonerId, :region]
end
