class Invitation < ApplicationRecord
	belongs_to :requester, class_name: 'User', foreign_key: 'user_id'
	belongs_to :team
end
