class CreateAdyenNotifications < ActiveRecord::Migration
  def self.up
    Adyen::Notification::Migration.migrate(:up)
  end

  def self.down
    Adyen::Notification::Migration.migrate(:down)
  end
end
