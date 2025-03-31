class AddFinalsToCohors < ActiveRecord::Migration[7.1]
  def change
    add_column :cohors, :is_final_tournament, :boolean, default: false
  end
end
