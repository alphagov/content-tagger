Rails.application.routes.draw do
  root to: 'taggings#lookup'

  resources :taxons

  resources :taggings, only: %i(show update), param: :content_id do
    get '/lookup', action: 'lookup', on: :collection
    get '/lookup/:slug', action: 'find_by_slug', on: :collection
    post '/lookup', action: 'find_by_slug', on: :collection
  end

  get '/content/:content_id', to: redirect { |params, _| "/taggings/#{params[:content_id]}" }
  get '/lookup', to: redirect("/taggings/lookup")

  resources :tagging_spreadsheets, except: %i(update edit), path: '/tag-importer' do
    post 'refetch'
    post 'publish_tags'
    get  'import_progress'
  end

  get '/healthcheck', to: proc { [200, {}, ['OK']] }

  resources :taxonomies, only: %i(show), param: :content_id

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: '/style-guide'

    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
