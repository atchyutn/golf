class AddLabelToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :label, :string
  end
end
