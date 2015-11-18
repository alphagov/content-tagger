Rails.application.routes.draw do
  root to: 'dashboard#show'

  get '/healthcheck', :to => proc { [200, {}, ['OK']] }

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
