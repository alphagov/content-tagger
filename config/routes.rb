Rails.application.routes.draw do
  root to: "application#redirect_to_home_page"

  namespace :taxonomy do
    resources :health_warnings, only: [:index]
  end

  resources :taxons do
    get :confirm_delete
    get :confirm_restore
    get :confirm_discard
    get :tagged_content
    get :history
    get :confirm_publish
    get :confirm_bulk_publish
    get :confirm_bulk_update
    get :download_tagged
    get :visualisation_data
    get :download, on: :collection
    post :publish
    post :bulk_publish
    post :bulk_update
    post :restore
    get :trash, on: :collection
    get :drafts, on: :collection
    delete :discard_draft
  end

  resources :taggings, only: %i[show update], param: :content_id do
    get "/lookup", action: "lookup", on: :collection
    get "/lookup-urls", action: "lookup_urls", on: :collection
    get "/lookup/:slug", action: "find_by_slug", on: :collection
    post "/lookup", action: "find_by_slug", on: :collection
  end

  get "/content/:content_id", to: redirect { |params, _| "/taggings/#{params[:content_id]}" }
  get "/lookup", to: redirect("/taggings/lookup")

  resources :projects, except: %i[edit update] do
    get :confirm_delete
    collection do
      resources :project_content_items, only: [:index]
    end

    resources :project_content_items, only: [:update], as: "content_item" do
      get "/flags", on: :member, to: "project_content_items#flags"
      post "/flags", on: :member, to: "project_content_items#update_flags", as: "update_flags"
      post "/done", on: :member, to: "project_content_items#mark_as_done", as: "mark_done"
    end
    post "/bulk_update", to: "project_content_items#bulk_update", as: "bulk_update"
  end

  resources :tagging_spreadsheets, except: %i[update edit], path: "/tag-importer" do
    post "refetch"
    post "publish_tags"
    get  "progress"
  end

  resources :taxon_migrations, only: %i[new create]

  resources :tag_migrations, only: %i[index new create show destroy] do
    post "publish_tags"
    get  "progress"
  end

  resource :bulk_tag, only: [:new] do
    get "results" => "bulk_tags#results", as: "search_results_for"
  end

  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  resources :taxonomies, only: %i[show], param: :content_id

  resources :tagging_history, only: %i[index show]

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"

    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end

  class ProxyAccessContraint
    def matches?(request)
      !request.env["warden"].try(:user).nil?
    end
  end

  mount Proxies::IframeAllowingProxy.new => Proxies::IframeAllowingProxy::PROXY_BASE_PATH, constraints: ProxyAccessContraint.new
end
