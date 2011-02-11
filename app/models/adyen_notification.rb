class AdyenNotification < ActiveRecord::Base
  belongs_to :payment
  belongs_to :original_notification, :class_name => "AdyenNotification", :foreign_key => "original_reference", :primary_key => "psp_reference"

  def handle!
    payment = if event_code == 'AUTHORISATION'
      order = Order.find_by_number(merchant_reference)
      Payment.create(:order_id => order.id, :payment_method => BillingIntegration::AdyenIntegration.current, :response_code =>  psp_reference)
    else
      original_notification.payment
    end
    update_attribute(:payment_id, payment.to_param)

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
    result = Adyen::API::PaymentService.capture(:currency => currency, :value => val, :original_reference => psp_reference) 

    result
  end

  # A notification should always include an event_code
  validates_presence_of :event_code
  
  # A notification should always include a psp_reference
  validates_presence_of :psp_reference
  
  # A notification should be unique using the composed key of
  # [:psp_reference, :event_code, :success]
  validates_uniqueness_of :success, :scope => [:psp_reference, :event_code]
  
  # Make sure we don't end up with an original_reference with an empty string
  before_validation { |notification| notification.original_reference = nil if notification.original_reference.blank? }
  
  # Logs an incoming notification into the database.
  #
  # @param [Hash] params The notification parameters that should be stored in the database.
  # @return [Adyen::Notification] The initiated and persisted notification instance.
  # @raise This method will raise an exception if the notification cannot be stored.
  # @see Adyen::Notification::HttpPost.log
  def self.log(params)
    converted_params = {}
    
    # Convert each attribute from CamelCase notation to under_score notation
    # For example, merchantReference will be converted to merchant_reference
    params.each do |key, value|
      column_name = key.to_s.underscore
      converted_params[column_name] = value if self.column_names.include?(column_name)
    end
    
    self.create!(converted_params)
  end

  # Returns true if this notification is an AUTHORISATION notification
  # @return [true, false] true iff event_code == 'AUTHORISATION'
  # @see Adyen.notification#successful_authorisation?
  def authorisation?
    event_code == 'AUTHORISATION'
  end

  alias :authorization? :authorisation?
  
  # Returns true if this notification is an AUTHORISATION notification and
  # the success status indicates that the authorization was successfull.
  # @return [true, false] true iff  the notification is an authorization
  #   and the authorization was successful according to the success field.
  def successful_authorisation?
    event_code == 'AUTHORISATION' && success?
  end
  
  alias :successful_authorization? :successful_authorisation?
end
