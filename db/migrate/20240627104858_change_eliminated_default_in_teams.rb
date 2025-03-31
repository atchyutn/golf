class ChangeEliminatedDefaultInTeams < ActiveRecord::Migration[7.1]
  def up
    change_column_default :teams, :eliminated, from: true, to: nil
  end

  def down
    change_column_default :teams, :eliminated, from: nil, to: true
  end
end
