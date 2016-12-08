class TaggingsController < ApplicationController
  def lookup
    @lookup = ContentLookupForm.new
  end

  def find_by_slug
    content_lookup = ContentLookupForm.new(lookup_params)

    if content_lookup.valid?
      redirect_to tagging_path(content_lookup.content_id)
    else
      @lookup = content_lookup
      render 'lookup'
    end
  end

  def show
    @content_item = ContentItem.find!(params[:content_id])
    @tagging_update = TaggingUpdateForm.from_content_item_links(@content_item.link_set)

    @tag_types = ContentItemLinks::TAG_TYPES - @content_item.blacklisted_tag_types
    @linkables = Linkables.new
  rescue ContentItem::ItemNotFoundError
    render "item_not_found", status: 404
  end

  def update
    tagging_update_form = TaggingUpdateForm.new(params[:tagging_update_form])
    tagging_update_form.publish!
    redirect_to :back, success: "Tags have been updated!"
  rescue GdsApi::HTTPConflict
    redirect_to :back, danger: "Somebody changed the tags before you could. Your changes have not been saved."
  end

private

  def lookup_params
    params[:content_lookup_form] || { base_path: "/#{params[:slug]}" }
  end
end
