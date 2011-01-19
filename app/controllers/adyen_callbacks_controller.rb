class AdyenCallbacksController < Spree::BaseController
  protect_from_forgery :except => :create
  before_filter :adyen_auth
  # possible transaction states
  TRANSACTION_STATES = ["ERROR", "RESERVED", "BILLED", "REVERSED", "CREDITED", "SUSPENDED"]

  # Confirmation interface is a GET request
  def create
    Adyen::Notification::HttpPost.log(request)
    notification = AdyenNotification.last
    notification.handle!
  rescue ActiveRecord::RecordInvalid => e
    # Validation failed, because of the duplicate check.
    # So ignore this notification, it is already stored and handled.
  ensure
    # Always return that we have accepted the notification
    render :text => '[accepted]'
  end
    
=begin
    notification = ActiveMerchant::Billing::Integrations::Adyen::Notification.new(request.query_string)
    
    order = Order.find_by_number(notification.item_id)

    case notification.event_code
    when "AUTHORISED"
      # check if the retrieved order is the same as the outgoing one
      if verify_currency(order, params["CURRENCY"])

        # create new payment object
        payment_details = MPaySource.create (
          :p_type => params["P_TYPE"],
          :brand => params["BRAND"],
          :mpayid => params["MPAYTID"]
        )

        payment_details.save!

        # TODO log the payment
        order.checkout.payments.create(
          :amount => params["PRICE"],
          :payment_method_id => nil,
          :source => payment_details
        )

        payment = order.checkout.payments.first
        payment.save!

        payment_details.payment = payment
        payment_details.save!

        price = order.total
        confirmed_price = params["PRICE"].to_i/100.0

        order.complete!

        # do the state change
        if price == confirmed_price
          order.pay!
        elsif price < confirmed_price
          order.over_pay!
        elsif price > confirmed_price
          order.under_pay!
        else
          raise "#{price} vs. #{confirmed price}".inspect
        end
      end
    when "RESERVED"
      raise "send the confirmation request out".inspect
    else
      raise "what is going on?".inspect
    end

    render :text => "OK", :status => 200
=end

  private

  def check_operation(operation)
    if operation != "CONFIRMATION"
      raise "unknown operation: #{operation}".inspect
    end
  end

  def check_status(status)
    if !TRANSACTION_STATES.include?(status)
      raise "unknown status: #{status}".inspect
    end
  end

  def find_order(tid)
    if (order = Order.find(tid)).nil?
      raise "could not find order: #{tid}".inspect
    end

    return order
  end

  def verify_currency(order, currency)
    "EUR" == currency
  end

  def adyen_auth
    preferred_user =  BillingIntegration::AdyenIntegration.current.preferred_notification_user
    preferred_password =  BillingIntegration::AdyenIntegration.current.preferred_notification_password
    authenticate_with_http_basic do |user, pass|
      user == preferred_user and pass == preferred_password
    end
  end
end
