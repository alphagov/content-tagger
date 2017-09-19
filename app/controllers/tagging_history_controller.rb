class TaggingHistoryController < ApplicationController
  before_action :ensure_user_can_access_tagathon_tools!

  def index
    render :index, locals: { page: TaggingHistory::IndexPage.new({ link_types: ['taxons'] }.merge(filter_params)) }
  end

  def show
    content_item = ContentItem.find!(params[:id])

    render :show,
           locals: {
             content_item: content_item,
             page: TaggingHistory::IndexPage.new(
               {
                 link_types: ['taxons'],
                 target_content_ids: [content_item.content_id],
               }.merge(filter_params)
             )
           }
  end

  def filter_params
    params.permit(users: []).to_h.symbolize_keys
  end
end
