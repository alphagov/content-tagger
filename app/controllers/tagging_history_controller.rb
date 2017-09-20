class TaggingHistoryController < ApplicationController
  before_action :ensure_user_can_access_tagathon_tools!

  def index
    render :index,
           locals: { link_changes: TaggingHistory::LinkChanges.new(filter_params) }
  end

  def show
    content_item = ContentItem.find!(params[:id])

    render :show,
           locals: {
             content_item: content_item,
             link_changes: TaggingHistory::LinkChanges.new(
               filter_params
                 .symbolize_keys
                 .merge(target_content_ids: [content_item.content_id])
             )
           }
  end

  def filter_params
    params.permit(users: [])
  end
end
