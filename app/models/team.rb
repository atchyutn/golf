class Team < ApplicationRecord
  belongs_to :home_course, optional: true
  belongs_to :cohors, optional: true
  belongs_to :tournament, optional: true
  has_many :match_teams, dependent: :destroy
  has_many :matches, through: :match_teams
  belongs_to :home_course, optional: true
  belongs_to :cohors, optional: true

  has_one :captain, -> { where(player_type: 'captain') }, class_name: 'User' , dependent: :destroy
  has_many :players, class_name: 'User' , dependent: :destroy
  has_many :reserved_players, -> { where(player_type: 'reserved_player') }, class_name: 'User' , dependent: :destroy

  enum payment_status: %i[incomplete pending completed]

  validate :validate_player_count
  validates_uniqueness_of :name
  validate :disqualify_if_no_completed_matches_and_upcoming_match_with_one_team

  before_create :set_name, :set_default_payment_status
  after_save :update_user_course
  after_update :is_disqualified

  scope :not_in_any_cohors, -> { where.not(id: Cohors.joins(:teams).pluck('teams.id')) }
  scope :not_in_any_cohors_except, ->(cohors) {
    team_ids_in_cohors = Cohors.find(cohors.id).teams.pluck('teams.id')
    team_ids_not_in_any_cohors = Team.where.not(id: Cohors.joins(:teams).pluck('teams.id')).pluck(:id)
    where(id: team_ids_not_in_any_cohors + team_ids_in_cohors)
  }

  def self.with_completed_payment_and_two_players
    joins(:players)
      .where(payment_status: 'completed', users: { player_type: ['player', 'captain'] })
      .group('teams.id')
      .having('COUNT(users.id) >= 2')
  end

  private

  # Validate that the team has at least 2 players
  def validate_player_count
    return if new_record?  # Allow new teams to be created
    # return if Rails.env.development? && ENV['SKIP_TEAM_PLAYER_VALIDATION']
    unless players.count >= 2
      errors.add(:base, "A team must have at least 2 players")
    end
  end

  # Set a default name if none is provided
  def set_name
    self.name = "team_#{SecureRandom.random_number(10**2)}" if self.name.nil?
  end

  # Set payment_status to completed by default
  def set_default_payment_status
    self.payment_status = 'completed'
  end

  # Update the user's home course
  def update_user_course
    captain.update(home_course_id: home_course_id) rescue nil
  end

  # Disqualify the team if they have no completed matches and an upcoming match with only one team
  def disqualify_if_no_completed_matches_and_upcoming_match_with_one_team
    if matches.any? && matches.completed.any? && matches.upcoming.count == 1
      upcoming_match = matches.upcoming.last
      if upcoming_match.present? && upcoming_match.teams.count == 1
        update(disqualified: true)
      end
    end
  end

  # Handle disqualification logic
  def is_disqualified
    return unless disqualified && saved_change_to_disqualified?

    @matches = matches.order(updated_at: :desc)
    @match = has_one_team? ? @matches.second : @matches.first
    return unless @match.present?

    team1 = Team.find_by(id: @match.player1_id)
    team2 = Team.find_by(id: @match.player2_id)
    scores = team1.id == id ? ["0-1"] : ["1-0"]
    scores_to_i = scores.first.split('-').map(&:to_i)

    if @match.completed? && (id == @match.winner_id)
      @match.update(scores_csv: scores)
    else
      @match.update(status: 'completed', scores_csv: scores)
    end
  end

  # Check if the team has only one upcoming match
  def has_one_team?
    @matches.first.upcoming? && @matches.first.teams.count == 1
  end
end