require 'adyen'
require 'adyen/api/payment_service'
require 'handsoap'
require 'active_merchant/billing/integrations/action_view_helper'
require 'active_merchant/billing/integrations/adyen'
require 'spree_core'

module SpreeAdyen
  class Engine < Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Handsoap::http_driver= :net_http
      Handsoap::xml_query_driver= :rexml

      Spree::BillingIntegration::AdyenIntegration.register

      Spree::CheckoutController.send :helper, Spree::AdyenHelper
      ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)
    end

    config.after_initialize do |app|
      app.config.spree.payment_methods += [
        Spree::BillingIntegration::AdyenIntegration
      ]
    end

    config.to_prepare &method(:activate).to_proc
  end
end

