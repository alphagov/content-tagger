class ContentController < ApplicationController
  def show
    @content_item = ContentItem.find!(params[:content_id])
    @tagging_update = TaggingUpdateForm.init_with_content_item(@content_item)
    @tag_types = ContentItem::TAG_TYPES - @content_item.blacklisted_tag_types
  rescue ContentItem::ItemNotFoundError
    render "item_not_found", status: 404
  end

  def update_links
    TaggingUpdateForm.new(params[:tagging_update_form]).publish!
    redirect_to :back, success: "Tags have been updated!"
  rescue GdsApi::HTTPConflict
    redirect_to :back, danger: "Somebody changed the tags before you could. Your changes have not been saved."
  end
end
