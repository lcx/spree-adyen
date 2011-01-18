class AddPaymentIdToNotifications < ActiveRecord::Migration
  def self.up
    add_column :adyen_notifications, :payment_id, :integer
  end

  def self.down
    remove_column :adyen_notifications, :payment_id
  end
end
