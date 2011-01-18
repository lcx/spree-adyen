require 'adyen'
require 'adyen/soap'
require 'active_merchant/billing/integrations/action_view_helper'
require 'active_merchant/billing/integrations/adyen'
require 'spree_core'

module SpreeAdyen
  class Engine < Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Handsoap::http_driver= :net_http
      Handsoap::xml_query_driver= :rexml

      BillingIntegration::AdyenIntegration.register
     
      CheckoutController.send :helper, ::AdyenHelper
      ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)
    end
    config.to_prepare &method(:activate).to_proc
  end
end

