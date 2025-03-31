class AddHandicapAndTeeColorToMatch < ActiveRecord::Migration[7.1]
  def change
    add_column :matches, :handicap, :float
    add_column :matches, :tee_color, :string
    change_column :matches, :status, :integer, default: 0
  end
end
