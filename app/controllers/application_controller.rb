class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger

  include GDS::SSO::ControllerMethods
  before_filter :require_signin_permission!
  before_filter :set_authenticated_user_header

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private

  helper_method(
    :active_navigation_item,
    :website_url,
    :similar_search_results_url
  )

  def website_url(base_path, draft: false)
    if draft
      Plek.new.find('draft-origin') + base_path
    else
      Plek.new.website_root + base_path
    end
  end

  def similar_search_results_url(base_path)
    Plek.new.find('search-admin') +
      "/similar-search-results/result?base_path=#{base_path}"
  end

  def active_navigation_item
    controller_name
  end

  def set_authenticated_user_header
    GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
  end
end
