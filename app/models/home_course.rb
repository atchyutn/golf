class HomeCourse < ApplicationRecord
  belongs_to :club
  has_many :users, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :matches, dependent: :destroy
  has_many :tees, dependent: :destroy
  has_many :holes, dependent: :destroy

  validates :name, presence: true
end
