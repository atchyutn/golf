class AddCohorsToMatch < ActiveRecord::Migration[7.1]
  def change
    add_column :matches, :cohors_id, :integer
  end
end
