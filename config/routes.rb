Rails.application.routes.draw do
  root to: 'lookup#new'

  controller :lookup do
    get '/lookup', action: :new, as: :taggings
    post '/lookup', action: :find_by_slug, as: :find_by_slug
  end

  controller :content do
    get '/content/:content_id', action: :show, as: :content
    post '/content/taggings', action: :update_links, as: :content_update_links
  end

  get '/healthcheck', to: proc { [200, {}, ['OK']] }

  mount GovukAdminTemplate::Engine, at: "/style-guide" if Rails.env.development?
end
