Rails.application.routes.draw do
  # will be used for sucess messages
  resources :adyen_confirmation, :only => [:index]

  # this is used to confirm payed orders
  resource :adyen_callbacks, :controller => 'adyen_callbacks', :only => [:create]
end
