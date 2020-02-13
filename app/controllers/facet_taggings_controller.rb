class FacetTaggingsController < ::TaggingsController

  def show
    content_item = ContentItem.find!(params[:content_id])

    render :show, locals: {
      tagging_update: Facets::TaggingUpdateForm.from_content_item(content_item),
    }
  rescue ContentItem::ItemNotFoundError
    render "item_not_found", status: :not_found
  end

  def update
    content_item = ContentItem.find!(params[:content_id])
    publisher = Facets::TaggingUpdatePublisher.new(
      content_item,
      params[:facets_tagging_update_form],
      params[:facet_group_content_id],
    )

    if publisher.save_to_publishing_api
      redirect_back(
        fallback_location: facet_group_facet_tagging_path(
          facet_group_content_id: params[:facet_group_content_id],
          content_id: content_item.content_id,
        ),
        success: "Facet values have been updated!",
      )
    else
      tagging_update = Facets::TaggingUpdateForm.from_content_item(content_item)
      tagging_update.update_attributes_from_form(params[:facets_tagging_update_form])

      flash.now[:danger] = "This form contains errors. Please correct them and try again."
      render :show, locals: { tagging_update: tagging_update }
    end
  rescue GdsApi::HTTPConflict
    redirect_back(
      fallback_location: facet_group_facet_tagging_path(
        facet_group_content_id: params[:facet_group_content_id],
        content_id: content_item.content_id,
      ),
      danger: "Somebody changed the tags before you could. Your changes have not been saved.",
    )
  end
end
