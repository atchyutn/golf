class AddPaymentStatusToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :payment_status, :integer, default: 0
  end
end
