class AnalyticsController < ApplicationController
  def show
    render :show, locals: { page: Analytics::IndexPage.new }
  end
end