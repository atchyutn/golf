class RemoveColumnFromMatch < ActiveRecord::Migration[7.1]
  def change
    remove_column :matches, :tee_color, :string
  end
end
