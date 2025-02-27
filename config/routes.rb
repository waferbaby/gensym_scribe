Rails.application.routes.draw do
  post "webhooks", to: "webhooks#index", format: :json
end
