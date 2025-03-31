class Hole < ApplicationRecord
  belongs_to :home_course
  belongs_to :tee, optional: true
  # has_many :hole_scores, dependent: :destroy
  has_many :tee_hole_infos, dependent: :destroy

  # Attributes
  # Assuming we need a par attribute
  # t.integer :par

  # Method to retrieve par value for the hole
  def self.get_par(hole_number)
    hole = find_by(number: hole_number)
    hole ? hole.par : nil # Return the par value if the hole exists, else nil
  end
end
