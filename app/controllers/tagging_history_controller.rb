class TaggingHistoryController < ApplicationController
  def index
    render :index,
           locals: { link_changes: TaggingHistory::LinkChanges.new(filter_params) }
  end

  def show
    content_item = ContentItem.find!(params[:id])

    render :show,
           locals: {
             content_item:,
             link_changes: TaggingHistory::LinkChanges.new(
               filter_params
                 .merge(target_content_ids: [content_item.content_id]),
             ),
           }
  end

  def filter_params
    params.permit(users: [])
  end
end
