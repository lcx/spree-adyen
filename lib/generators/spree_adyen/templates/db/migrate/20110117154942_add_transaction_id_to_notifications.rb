class AddTransactionIdToNotifications < ActiveRecord::Migration
  def self.up
    add_column :adyen_notifications, :adyen_transaction_id, :integer
  end

  def self.down
    remove_column :adyen_notifications, :adyen_transaction_id
  end
end
