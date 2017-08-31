class AnalyticsController < ApplicationController
  before_action :ensure_user_can_access_tagathon_tools!

  def index
    render :index, locals: { page: Analytics::IndexPage.new }
  end

  def activity
    render :activity, locals: { page: Analytics::ActivityPage.new(params) }
  end

  def show
    render :show, locals: { page: Analytics::ShowPage.new(params[:taxon_id]) }
  end

  def trends
    if time_span_query
      render :trends, locals: { page: Analytics::TrendsPage.new(time_span_query) }
    else
      redirect_to trends_path(query: Analytics::TrendsPage::DEFAULT_QUERY)
    end
  end

private

  def time_span_query
    params[:query] if allowable_time_query?
  end

  def allowable_time_query?
    Analytics::TrendsPage.queries.include? params[:query]
  end
end
