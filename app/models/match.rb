class Match < ApplicationRecord
  belongs_to :home_course, optional: true
  belongs_to :cohors, class_name: 'Cohors', optional: true
  has_many :match_teams, dependent: :destroy
  has_many :teams, through: :match_teams
  has_many :match_tees, dependent: :destroy
  has_many :tees, through: :match_tees
  belongs_to :cohors
  has_many :hole_scores, dependent: :destroy
  has_many :course_handicaps, dependent: :destroy
  has_many :users_tees, dependent: :destroy
  has_one :chat_room, dependent: :destroy

  # Define associations for winner and loser
  belongs_to :winner, class_name: 'Team', optional: true
  belongs_to :loser, class_name: 'Team', optional: true

  enum status: %i[upcoming completed started]

  scope :upcoming, -> { where('match_time > ?', Time.current) }
  scope :complete, -> { where(status: :completed) }

  # validates :match_id, presence: true
  validate :must_belong_to_tournament_or_cohors

  after_create :create_chat_room
  after_update :update_tournament_progression, if: :saved_change_to_status?
  after_update :send_notification, if: :saved_change_to_match_time?

  # Update tournament progression after a match is completed
  def update_tournament_progression
    return unless completed?

    case cohors.tournament_type
    when "single_elimination"
      update_single_elimination_match
    when "double_elimination"
      update_double_elimination_match
    end
  end

  # Find the captain of the home team
  def home_team_captain
    # Assuming the first team is the home team
    first_team = teams.first
    first_team&.players&.find_by(team_captain: true)
  end

  def chat_users
    teams.includes(:players).flat_map(&:players).uniq
  end

  def unread_message_count_for(user)
    return 0 unless chat_room
    
    chat_room.messages
             .includes(:message_reads)
             .where(message_reads: { user_id: user.id, read: false })
             .count
  end

  def ensure_chat_room
    chat_room || create_chat_room
  end

  private

  def create_chat_room
    ChatRoom.create!(match: self) unless chat_room
  end

  def send_notification
    players = User.includes(team: :matches).where(matches: { id: })
    players.each do |player|
      UserNotifierMailer.with(player:, match: self).match_announcement.deliver_later
    rescue Net::OpenTimeout => e
      logger.error "Failed to send email to #{player.email}: #{e.message}"
      # Skip this error and continue with the next player
    end
  end

  # Update progression for single elimination
  def update_single_elimination_match
    next_round_matches = cohors.matches.where(round: round + 1)
    next_round_matches.each do |match|
      if match.player1_id.nil?
        match.update(player1_id: winner_id)
      else
        match.update(player2_id: winner_id)
      end
      if match.persisted? && match.player1_id && match.player2_id
        MatchTeam.find_or_create_by(match: match, team_id: match.player1_id)
        MatchTeam.find_or_create_by(match: match, team_id: match.player2_id)
      end
    end
  end

  # Update progression for double elimination
  def update_double_elimination_match
    if bracket == "winners"
      # Move the loser to the losers' bracket
      losers_match = cohors.matches.find_by(round: round + 1, bracket: "losers")
      if losers_match
        if losers_match.player1_id.nil?
          losers_match.update(player1_id: loser_id)
        else
          losers_match.update(player2_id: loser_id)
        end
      end
    end
  end

  # Validate that the match belongs to a tournament or cohors
  def must_belong_to_tournament_or_cohors
    unless tournament_id.present? || cohors_id.present?
      errors.add(:base, 'Match must belong to either a Tournament or a Cohors.')
    end
  end

  def home_team_captain
    home_team = teams.find_by(home: true)
    home_team ? home_team.captain : nil
  end
end