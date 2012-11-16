class Spree::AdyenConfirmationController < Spree::BaseController
  include ActiveMerchant::Billing::Integrations
  protect_from_forgery :except => :index

  # this action is called by Adyen
  # and _not_ by the end user
  def index
    notify = ActiveMerchant::Billing::Integrations::Adyen::Notification.new(request.query_string)

    @order = Spree::Order.find_by_number(notify.item_id)

    begin
      if notify.complete?
        logger.debug("Order id: #{@order.id} paid") 
        @order.update_attributes({:state => "complete", :completed_at => Time.now}, :without_protection => true)
        @order.finalize!
        flash[:notice] = I18n.t(:order_processed_successfully)
        redirect_to order_path(@order)
      else
        logger.error("Couldn't verify payment! Order id: #{@order.id}")
        flash[:error] = I18n.t(:order_process_error)
        redirect_to checkout_state_path(:payment, :order => @order)
      end
    rescue => e
      raise
    end
  end
end
