Rails.application.routes.draw do
  # will be used for sucess messages
  resources :adyen_callbacks, :only => [:index]

  # this is used to confirm payed orders
  resource :adyen_confirmation, :controller => 'adyen_confirmation', :only => [:show]
end
