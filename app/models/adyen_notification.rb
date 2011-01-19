class AdyenNotification < ActiveRecord::Base
  belongs_to :payment
  belongs_to :original_notification, :class_name => "AdyenNotification", :foreign_key => "original_reference", :primary_key => "psp_reference"

  def handle!
    if event_code == 'AUTHORISATION'
      update_attribute(:payment_id, Payment.find_by_response_code(psp_reference).to_param)
    else
      update_attribute(:payment_id, original_notification.payment_id)
    end

    if success?
      case event_code
      when 'AUTHORISATION'
        payment.started_processing!
        call_capture
        update_attribute(:processed, true)
      when 'CAPTURE'
        payment.complete!
        update_attribute(:processed, true)
      when 'CANCEL_OR_REFUND', 'RECURRING_CONTRACT'
        raise 'Not implemented yet'
      end
    end
  end

  def call_capture
    val = (value.to_f * 100).truncate
    result = Adyen::SOAP::PaymentService.capture(:currency => currency, :value => val, :original_reference => psp_reference) 
    puts result
  end
end
