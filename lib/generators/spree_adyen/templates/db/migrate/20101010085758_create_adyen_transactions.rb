class CreateAdyenTransactions < ActiveRecord::Migration
  def self.up
    create_table :adyen_transactions do |t|
      t.string :psp_reference
      t.string :response
      t.integer :payment_id

      t.timestamps
    end
    Adyen::Notification::Migration.migrate(:up)
  end

  def self.down
    Adyen::Notification::Migration.migrate(:down)
    drop_table :adyen_transactions
  end
end
