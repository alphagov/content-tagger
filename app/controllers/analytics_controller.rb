class AnalyticsController < ApplicationController
  before_action :ensure_user_can_access_tagathon_tools!

  def show
    render :show, locals: { page: Analytics::IndexPage.new }
  end
end