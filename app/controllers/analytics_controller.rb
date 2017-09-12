class AnalyticsController < ApplicationController
  before_action :ensure_user_can_access_tagathon_tools!

  def show
    render :show, locals: { page: Analytics::IndexPage.new({link_types: ['taxons']}.merge(filter_params))}
  end

  def filter_params
    params.permit(users: []).to_h.symbolize_keys
  end

end