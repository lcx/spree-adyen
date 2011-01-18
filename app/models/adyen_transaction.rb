class AdyenTransaction < ActiveRecord::Base
  belongs_to :payment
  has_many :adyen_notifications

  def payment_gateway
     BillingIntegration::AdyenIntegration.current
  end

  
end
