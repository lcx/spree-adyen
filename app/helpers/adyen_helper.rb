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

      details = order_details(order)
      service.set_order_data details

      service.skinCode(payment_method.preferred_skin)
 
      service.shared_secret(payment_method.preferred_hmac)
      service.return_url("#{root_url}adyen_callbacks")
    end
    content
  end

  def order_details(order)
    details = "<p>Order nr: #{order.number}</p>"
    order.line_items.each {|li| details << "<p>#{li.quantity} #{li.variant.product.name}: #{li.price}</p>"}
    details << "<p>Shipment: #{order.shipping_cost}</p>"
    details << "<p>Coupon: #{order.discount.amount}</p>" if order.discount
    details << "<p>VAT: #{order.vat_amount}</p>"
    details << "<p>Total: #{order.total}</p>"
    pp details
    details
  end
end
