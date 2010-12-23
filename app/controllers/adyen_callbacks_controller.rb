class AdyenCallbacksController < Spree::BaseController
  include ActiveMerchant::Billing::Integrations
#  before_filter :adyen_auth
  protect_from_forgery :except => :index

  # this action is called by Adyen
  # and _not_ by the end user
  def index
    notify = ActiveMerchant::Billing::Integrations::Adyen::Notification.new(request.query_string)

    @order = Order.find_by_number(notify.item_id)
    begin
      if notify.complete?
        @order.payments << Payment.create(:order => @order, :source => BillingIntegration::Adyen.current, :response_code => notify.event_code)
      else
        logger.error("Couldn't verify payment! Order id: #{@order.id}")
      end
    rescue => e
      raise
    ensure
      @order.save!
    end
    redirect_to update_checkout_path(:payment, :order => @order)
  end

  private
  def adyen_auth
    authenticate_or_request_with_http_basic do |user, pass|
      user == ADYEN_NOTIFY_USER and pass == ADYEN_NOTIFY_PASS
    end
  end

end
