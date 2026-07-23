Rails.application.routes.draw do
  root "catalog#new"
  post "catalog", to: "catalog#create", as: :catalog
end
