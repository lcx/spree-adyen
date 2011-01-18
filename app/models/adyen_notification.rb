class AdyenNotification < ActiveRecord::Base
  belongs_to :adyen_transaction
  belongs_to :original_notification, :class_name => "AdyenNotification", :foreign_key => "original_reference", :primary_key => "psp_reference"

  def handle!
    pp self
    if success?
      case event_code
      when 'AUTHORISATION'

        # A payment authorized successfully, so handle the payment
        # ...
        # flag the notification so we know that it has been processed
        # User.find(shopper_reference.to_i).renew_premium!(1.month)
        time_of_premiumness = AMOUNTS.invert[(value * 100).to_i].months
        adyen_transaction.mark_as_authorirized!
        update_attribute(:processed, true)
      when 'CANCEL_OR_REFUND'
        time_of_premiumness = AMOUNTS.invert[(original_notification.value * 100).to_i].months
        User.find(merchant_reference.to_i).cancel_premium!(time_of_premiumness)
        update_attribute(:processed, true)
      when 'RECURRING_CONTRACT'
        # Handle a new recurring contract
        # ...
        update_attribute(:processed, true)
      end
    end
  end
end
