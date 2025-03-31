class Tournament < ApplicationRecord
	belongs_to :region, optional: true

	validates :url, presence: true

	enum state: %i[ pending group_stages_underway complete ]
end
