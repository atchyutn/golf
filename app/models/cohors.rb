class Cohors < ApplicationRecord
  belongs_to :region
  has_many :teams
  has_many :matches, dependent: :destroy

  enum tournament_type: {
    single_elimination: 0,
    double_elimination: 1
  }
  enum state: %w[pending underway complete awaiting_review]

  validates :name, :starts_at, :description, presence: true
  validates :name, uniqueness: true
  validate :start_at_should_be_now_or_future

  after_create :create_brackets
  after_update :update_brackets
  after_destroy :cleanup_brackets
  
  def start_at_should_be_now_or_future
    if starts_at.present? && starts_at < DateTime.now
      errors.add(:starts_at, "should be today or any future date")
    end
  end

  def create_brackets
    TournamentService.new(self).generate_matches
  end  

  def update_brackets
    matches.destroy_all
    create_brackets
  end

  def cleanup_brackets
    matches.destroy_all
    teams.update_all(tournament_id: nil)
  end
end
