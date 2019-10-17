Rails.application.routes.draw do
  resources :translations, only: %i(new create)

  root to: redirect("/translations/new")
end
