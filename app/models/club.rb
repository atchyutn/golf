class Club < ApplicationRecord
	has_many :home_courses, dependent: :destroy
	has_many :tees, dependent: :destroy
end
