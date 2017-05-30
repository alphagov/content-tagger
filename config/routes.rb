Rails.application.routes.draw do
  root to: 'taggings#lookup'

  resources :taxons do
    get :confirm_delete
    get :confirm_restore
    get :confirm_discard
    get :confirm_publish
    get :download_tagged
    post :publish
    post :restore
    get :trash, on: :collection
    get :drafts, on: :collection
    delete :discard_draft
  end

  resources :copy_taxons, only: [:index], path: 'copy-taxons'

  resources :taggings, only: %i(show update), param: :content_id do
    get '/lookup', action: 'lookup', on: :collection
    get '/lookup-urls', action: 'lookup_urls', on: :collection
    get '/lookup/:slug', action: 'find_by_slug', on: :collection
    post '/lookup', action: 'find_by_slug', on: :collection
  end

  get '/content/:content_id', to: redirect { |params, _| "/taggings/#{params[:content_id]}" }
  get '/lookup', to: redirect("/taggings/lookup")

  resources :tagging_spreadsheets, except: %i(update edit), path: '/tag-importer' do
    post 'refetch'
    post 'publish_tags'
    get  'progress'
  end

  resources :taxon_migrations, only: [:new, :create]

  resources :tag_migrations, only: [:index, :new, :create, :show, :destroy] do
    post 'publish_tags'
    get  'progress'
  end

  resource :bulk_tag, only: [:new] do
    get 'results' => 'bulk_tags#results', as: "search_results_for"
  end

  get '/healthcheck', to: proc { [200, {}, ['OK']] }

  resources :taxonomies, only: %i(show), param: :content_id

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: '/style-guide'

    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
