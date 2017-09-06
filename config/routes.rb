Rails.application.routes.draw do
  root to: 'application#redirect_to_home_page'

  resources :taxons do
    get :confirm_delete
    get :confirm_restore
    get :confirm_discard
    get :confirm_publish
    get :confirm_bulk_publish
    get :download_tagged
    get :download, on: :collection
    post :publish
    post :bulk_publish
    post :restore
    get :trash, on: :collection
    get :drafts, on: :collection
    delete :discard_draft
  end

  get '/analytics' => 'analytics#index'
  get '/analytics/activity' => 'analytics#activity', as: :activity
  get '/analytics/trends(/:query)' => 'analytics#trends', as: :trends
  get '/analytics/:taxon_id' => 'analytics#show', as: :taxon_history

  resources :taggings, only: %i(show update), param: :content_id do
    get '/lookup', action: 'lookup', on: :collection
    get '/lookup-urls', action: 'lookup_urls', on: :collection
    get '/lookup/:slug', action: 'find_by_slug', on: :collection
    post '/lookup', action: 'find_by_slug', on: :collection
  end

  get '/content/:content_id', to: redirect { |params, _| "/taggings/#{params[:content_id]}" }
  get '/lookup', to: redirect("/taggings/lookup")

  resources :projects, only: %i(index show new create) do
    resources :project_content_items, only: [:update], as: 'content_item'
    post '/bulk_update', to: 'project_content_items#bulk_update', as: 'bulk_update'
  end

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

  resources :root_taxons, only: [:index, :show]
  resource :root_taxons, only: [:update]

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: '/style-guide'

    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  class ProxyAccessContraint
    def matches?(request)
      !request.env['warden'].try(:user).nil?
    end
  end

  mount Proxies::IframeAllowingProxy.new => Proxies::IframeAllowingProxy::PROXY_BASE_PATH, constraints: ProxyAccessContraint.new
end
