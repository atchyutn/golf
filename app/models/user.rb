# frozen_string_literal: true

class User < ApplicationRecord
  include ChallongeApi
  MAGIC_LINK_EXPIRATION_TIME = 1.day
  UK_PHONE_REGEX = /\A(\+44|0)\d{10,11}\z/
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]

  belongs_to :team
  belongs_to :home_course, optional: true
  has_many :invitations, dependent: :destroy
  has_many :hole_scores, dependent: :destroy
  has_many :course_handicaps, dependent: :destroy
  has_many :users_tees, dependent: :destroy
  has_many :tees, through: :users_tees
  has_many :messages, dependent: :destroy
  has_many :message_reads, dependent: :destroy

  has_one_attached :image

  validates :first_name, presence: true, on: :update
  validates :phone_number,
            format: { with: UK_PHONE_REGEX, message: 'must be a valid UK phone number and cannot contain special characters' }, 
            allow_blank: true

  enum player_type: %i[captain reserved_player player]

  before_create :generate_magic_link_token
  after_create :send_magic_link
  before_validation :set_random_password, on: :create, if: :password_blank?

  scope :only_players, -> { where.not(player_type: 'reserved_player') }

  def send_magic_link
    return if Rails.env.development? && ENV['SKIP_MAGIC_LINK']

    return if provider == 'google'

    generate_magic_link_token

    UserNotifierMailer.magic_link(self).deliver_now
  end

  def generate_magic_link_token
    self.magic_link_token = {
      token: SecureRandom.urlsafe_base64,
      expires_at: MAGIC_LINK_EXPIRATION_TIME.from_now
    }
  end

  def generate_unique_team_name
    base_name = "team-#{SecureRandom.alphanumeric(6).downcase}" # Generates "team-xyz123"
    team_name = base_name
    count = 1
  
    while Team.exists?(name: team_name)
      team_name = "#{base_name}-#{count}" # Adds a number if a duplicate exists
      count += 1
    end
  
    team_name
  end
  
  def add_to_team(invite_id = nil, home_course_id = nil)
    if invite_id
      invitation = Invitation.find(invite_id)
      Team.find_by(id: invitation.team_id)
      self.team_id = invitation.team_id
      self.player_type = invitation.player_type
      self.email = invitation.invitee_email
    elsif captain?
      build_team(home_course_id:).save
    end
  end
  

  def full_name
    "#{first_name} #{last_name}"
  end

  def magic_link_token_expired?
    return true unless magic_link_token.present?

    expires_at = magic_link_token.match(/:expires_at=>(.*? UTC)/)[1].to_datetime
    Time.now > expires_at
  end

  def self.from_omniauth(auth)
    user = find_by(email: auth[:email])

    if user.nil?
      user = new(email: auth[:email], provider: 'google', uid: auth[:uid])
      user.password = Devise.friendly_token[0, 20]
    else
      user.provider = 'google'
      user.uid = auth[:uid]
    end
    user.add_to_team(auth[:invite_id])
    user.save

    user
  end

  def home_team_captain?
    team.home && captain?
  end

  def team_captain
    player_type == 'captain'
  end
  # Update online status
  def go_online!
    update(online: true)
  end

  def go_offline!
    update(online: false)
  end

  private

  def set_random_password
    self.password = self.password_confirmation = SecureRandom.hex(10)
  end

  def password_blank?
    password.blank?
  end
end
