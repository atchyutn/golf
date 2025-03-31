class Location < ApplicationRecord
	# has_many :home_courses, dependent: :destroy
	has_many :clubs, dependent: :destroy
end
