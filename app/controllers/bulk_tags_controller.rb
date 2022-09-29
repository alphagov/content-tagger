class BulkTagsController < ApplicationController
  before_action :ensure_user_can_administer_taxonomy!

  def new
    render :new,
           locals: {
             search_results: BulkTagging::EmptySearchResponse.new,
             query: "",
           }
  end

  def results
    render :new, locals: { search_results: search_response, query: }
  end

private

  def search_response
    @search_response ||= BulkTagging::Search.call(query:, page:)
  end

  def page
    params[:page] || 1
  end

  def query
    search_params[:query]
  end

  def search_params
    params.require(:bulk_tag).permit(:query)
  end
end
