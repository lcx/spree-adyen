module Spree
  module AdyenHelper
    def adyen_form(order)
      payment_method = BillingIntegration::AdyenIntegration.current
      content = payment_service_for( order.id,
                                     payment_method.merchant_id,
                                     :payment_method_id => payment_method.id,
                                     :amount => amount_in_cents(order.total),
                                     :currency => 'EUR',
                                     :service => :adyen,
                                     :html => { :id => 'adyen-payment-form' } ) do |service|
        service.order order.number
        service.shipping order.ship_total
        service.tax order.tax_total

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
      details << "<p>Shipment: #{order.ship_total}</p>"
      details << "<p>Coupon: #{order.adjustments.eligible.promotion.map(&:amount).sum}</p>" if order.adjustments.eligible.promotion.map(&:amount).sum > 0
      details << "<p>VAT: #{order.tax_total}</p>"
      details << "<p>Total: #{order.total}</p>"
      details
    end

    private

    def amount_in_cents(amount)
      (100 * amount).to_i
    end
  end
end
