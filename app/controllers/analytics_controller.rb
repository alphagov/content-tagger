class AnalyticsController < ApplicationController
  def index
    render :index, locals: { page: Analytics::IndexPage.new }
  end

  def activity
    render :activity, locals: { page: Analytics::ActivityPage.new(params) }
  end

  def show
    render :show, locals: { page: Analytics::ShowPage.new(params[:taxon_id]) }
  end
end
