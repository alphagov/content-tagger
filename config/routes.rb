Rails.application.routes.draw do
  root to: 'dashboard#show'

  get '/healthcheck', to: proc { [200, {}, ['OK']] }

  mount GovukAdminTemplate::Engine, at: "/style-guide" if Rails.env.development?
end
