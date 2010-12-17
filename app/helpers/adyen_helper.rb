module AdyenHelper
  def adyen_form(order)
    content = payment_service_for( order.id,
                         order.payment_method.merchant_id,
                         :amount => order.amount_in_cents,
                         :currency => 'EUR',
                         :service => :adyen,
                         :html => { :id => 'payment_form' } ) do |service|
      service.order order.number
      service.shipping order.shipping_cost
      service.tax order.tax

      service.set_order_data 'Please pay for your order with Raz*War'
      service.skinCode(order.payment_method.preferred_skin)
 
      service.shared_secret(order.payment_method.preferred_hmac)
      service.return_url("#{root_url}checkout_complete")
    end
    content
  end
end
