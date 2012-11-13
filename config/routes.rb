Spree::Core::Engine.routes.draw do
  # will be used for sucess messages
  match '/adyen_confirmation' => 'adyen_confirmation#index'

  # this is used to confirm payed orders
  match '/adyen_callbacks' => 'adyen_callbacks#create'
end
