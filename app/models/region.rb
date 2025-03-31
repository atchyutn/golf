class Region < ApplicationRecord
	has_many :tournaments
	has_many :cohors, class_name: 'Cohors'

	validates :name, presence: true
end
