class Tee < ApplicationRecord
	belongs_to :home_course, optional: true
	belongs_to :user, optional: true
	belongs_to :club, optional: true
	has_many :holes, dependent: :destroy
	has_many :match_tees, dependent: :destroy
	has_many :matches, through: :match_tees
	has_many :tee_hole_infos, dependent: :destroy
	
	enum gender: %i[man woman]
end
