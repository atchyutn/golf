class UsersTee < ApplicationRecord
  belongs_to :user
  belongs_to :tee
  belongs_to :match
end
