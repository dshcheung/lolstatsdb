class MatchDetail < ActiveRecord::Base
  serialize :participants, Array
  serialize :participant_identities, Array

  validates_uniqueness_of :matchId, scope: :region
end
