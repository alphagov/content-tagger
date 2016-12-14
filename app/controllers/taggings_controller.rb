class TaggingsController < ApplicationController
  def lookup
    @lookup = ContentLookupForm.new
  end

  def find_by_slug
    respond_to do |format|
      format.json {json_lookup}
      format.html {html_lookup}
    end
  end

  def show
    @content_item = ContentItem.find!(params[:content_id])
    @tagging_update = TaggingUpdateForm.from_content_item_links(@content_item.link_set)
    @tag_types = @content_item.allowed_tag_types
    @linkables = Linkables.new
  rescue ContentItem::ItemNotFoundError
    render "item_not_found", status: 404
  end

  def update
    tagging_update_form = TaggingUpdateForm.new(params[:tagging_update_form])
    content_item = ContentItem.find!(params[:content_id])
    tag_types = content_item.allowed_tag_types

    if tagging_update_form.valid?
      Services.publishing_api.patch_links(
        tagging_update_form.content_id,
        links: tagging_update_form.links_payload(tag_types),
        previous_version: tagging_update_form.previous_version.to_i,
      )

      redirect_to :back, success: "Tags have been updated!"
    else
      @content_item = content_item
      @tagging_update = tagging_update_form
      @tag_types = content_item.allowed_tag_types
      @linkables = Linkables.new

      flash.now[:danger] = "This form contains errors. Please correct them and try again."
      render 'show'
    end
  rescue GdsApi::HTTPConflict
    redirect_to :back, danger: "Somebody changed the tags before you could. Your changes have not been saved."
  end

private

  def html_lookup
    content_lookup = ContentLookupForm.new(lookup_params)

    if content_lookup.valid?
      redirect_to tagging_path(content_lookup.content_id)
    else
      @lookup = content_lookup
      render 'lookup'
    end
  end

  def json_lookup
    content_lookup = ContentLookupForm.new(lookup_params)

    if content_lookup.valid?
        content_item = ContentItem.find!(content_lookup.content_id)
        render json: {
          base_path: content_item.base_path,
          content_id: content_item.content_id,
          title: content_item.title
        }
    else
      render json: {errors: content_lookup.errors}, status: 404
    end
  rescue ContentItem:: ItemNotFoundError
    render json: {errors: []}, status: 404
  end

  def lookup_params
    params[:content_lookup_form] || { base_path: "/#{params[:slug]}" }
  end
end
