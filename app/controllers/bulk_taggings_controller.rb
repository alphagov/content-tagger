class BulkTaggingsController < ApplicationController
  def new
    render :new, locals: { results: [] }
  end

  def search
    query = params[:collection_search][:query]
    gds_response = Services.publishing_api.get_content_items(
      document_type: "document_collection",
      per_page: 20,
      q: query
    )

    results = gds_response['results'].map { |result| ContentItem.new(result) }

    render :new, locals: { results: results }
  end

  private

  def search_params
    params.require(:collection_search).permit(:query)
  end
end
