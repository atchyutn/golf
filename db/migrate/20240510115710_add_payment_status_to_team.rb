class AddPaymentStatusToTeam < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :payment_status, :integer, default: 0
    add_column :teams, :paid_by, :string
  end
end
