class AdyenCallbacksController < Spree::BaseController
  include ActiveMerchant::Billing::Integrations
  before_filter :adyen_auth
  protect_from_forgery :except => :notify

  # this action is called by Adyen
  # and _not_ by the end user
  def index
    notify = Adyen::Notification.new(request.raw_post)
    raise "Deal with me!" unless ["AUTHORISATION", "NOTIFICATIONTEST"].include? notify.event_code 

    if notify.event_code
      @order = Order.find(notify.item_id)
      begin
        if notify.complete?
          @order.status = Order::STATUSES[:to_deliver]
          @order.psp_reference = notify.transaction_id
        else
          logger.error("Couldn't verify payment! Order id: #{@order.id}")
        end
      rescue => e
        raise
      ensure
        @order.save!
      end
    end
    render :text => "[accepted]"
  end

  private
  def adyen_auth
    authenticate_or_request_with_http_basic do |user, pass|
      user == ADYEN_NOTIFY_USER and pass == ADYEN_NOTIFY_PASS
    end
  end

end
