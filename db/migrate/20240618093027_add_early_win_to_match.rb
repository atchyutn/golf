class AddEarlyWinToMatch < ActiveRecord::Migration[7.1]
  def change
    add_column :matches, :early_win, :boolean, default: false
  end
end
