class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger

  include GDS::SSO::ControllerMethods
  before_filter :require_signin_permission!

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
