Rails.application.routes.draw do
  
  get 'about/me'

  get 'about_me/index'

  get 'about_me/about_me'

  get 'wishes/create_invoice'

  get 'wishes/check_payment'

  get 'wishes/get_count'

  get 'wishes/update_email'

  get 'wishes/save_wish'

  get 'wishes/generate_qr'

  get 'wishes/convert_coin_to_bitcoins'
  
  get 'home/index'
  
  root 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
