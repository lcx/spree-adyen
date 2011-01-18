module AdyenHelper
  def adyen_form(order)
    payment_method = BillingIntegration::AdyenIntegration.current
    content = payment_service_for( order.id,
                                   payment_method.merchant_id,
                                   :amount => order.amount_in_cents.to_i,
                                   :currency => 'EUR',
                                   :service => :adyen,
                                   :html => { :id => 'payment_form' } ) do |service|
      service.order order.number
      service.shipping order.shipping_cost
      service.tax order.tax

      service.set_order_data 'Please pay for your order with Raz*War'
      service.skinCode(payment_method.preferred_skin)
 
      service.shared_secret(payment_method.preferred_hmac)
      service.return_url("#{root_url}adyen_callbacks")
    end
    content
  end
end
