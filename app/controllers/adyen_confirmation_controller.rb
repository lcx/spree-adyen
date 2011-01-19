class AdyenConfirmationController < Spree::BaseController
  include ActiveMerchant::Billing::Integrations
  protect_from_forgery :except => :index

  # this action is called by Adyen
  # and _not_ by the end user
  def index
    notify = ActiveMerchant::Billing::Integrations::Adyen::Notification.new(request.query_string)

    @order = Order.find_by_number(notify.item_id)
    begin
      if notify.complete?
        logger.debug("Order id: #{@order.id} paid") 
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

end
