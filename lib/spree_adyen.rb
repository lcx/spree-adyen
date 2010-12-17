require 'active_merchant/billing/integrations/action_view_helper'
require 'spree_core'

module SpreeAdyen
  class Engine < Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      BillingIntegration::Adyen.register
     
      CheckoutController.send :helper, ::AdyenHelper
      ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)
    end
    config.to_prepare &method(:activate).to_proc
  end
end

