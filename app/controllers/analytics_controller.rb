class AnalyticsController < ApplicationController
  def index
    render :index, locals: { page: Analytics::IndexPage.new(params) }
  end
end
