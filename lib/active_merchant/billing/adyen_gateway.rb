module ActiveMerchant
  module Billing
    class AdyenGateway < Gateway
      class_attribute :test_mode

      self.test_mode = true

      def initialize(test_url, test_merchant_id, production_url, production_merchant_id)
        self.test_redirect_url = test_url
        self.test_merchant_id = test_merchant_id

        self.production_redirect_url = production_url
        self.production_merchant_id = production_merchant_id
      end

      # move this to the other thing?
      def gateway_url
        self.test_mode == true ? self.test_redirect_url : self.production_redirect_url
      end

      def merchant_id
        self.test_mode == true ? self.test_merchant_id : self.production_merchant_id
      end
    end
  end
end
