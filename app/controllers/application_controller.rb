class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger

  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!
  before_action :set_authenticated_user_header

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def redirect_to_home_page
    if user_can_manage_taxonomy?
      redirect_to taxons_path
    elsif user_can_access_tagathon_tools?
      redirect_to projects_path
    else
      redirect_to taxons_path
    end
  end

private

  helper_method(
    :active_navigation_item,
    :website_url,
    :similar_search_results_url,
    :user_can_administer_taxonomy?,
    :user_can_manage_taxonomy?,
    :user_can_access_tagathon_tools?,
  )

  delegate :user_can_administer_taxonomy?,
           :user_can_manage_taxonomy?,
           :user_can_access_tagathon_tools?,
           to: :permission_checker

  def ensure_user_can_administer_taxonomy!
    deny_access_to(:feature) unless user_can_administer_taxonomy?
  end

  def ensure_user_can_manage_taxonomy!
    deny_access_to(:feature) unless user_can_manage_taxonomy?
  end

  def ensure_user_can_access_tagathon_tools!
    deny_access_to(:feature) unless user_can_access_tagathon_tools?
  end

  def deny_access_to(subject)
    raise PermissionDeniedException, "Sorry, you are not authorised to access this #{subject}."
  end

  def permission_checker
    @permission_checker ||= PermissionChecker.new(current_user)
  end

  def website_url(base_path, draft: false)
    if draft
      Plek.new.external_url_for("draft-origin") + base_path
    else
      Plek.new.website_root + base_path
    end
  end

  def similar_search_results_url(base_path)
    Plek.new.external_url_for("search-admin") +
      "/similar-search-results/result?base_path=#{base_path}"
  end

  def active_navigation_item
    controller_name
  end

  def set_authenticated_user_header
    GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
  end
end
