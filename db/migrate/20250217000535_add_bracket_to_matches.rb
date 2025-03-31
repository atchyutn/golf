class AddBracketToMatches < ActiveRecord::Migration[7.1]
  def change
    add_column :matches, :bracket, :string
  end
end
