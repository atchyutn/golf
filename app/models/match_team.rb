class MatchTeam < ApplicationRecord
  belongs_to :match
  belongs_to :team

  validates_uniqueness_of :team_id, scope: :match_id
end
