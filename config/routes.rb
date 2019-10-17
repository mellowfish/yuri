Rails.application.routes.draw do
  resources :translations, only: %i(new create)

  get "/" => "translations#new"
  get "translations" => "translations#new"

  root to: redirect("/translations/new")
end
