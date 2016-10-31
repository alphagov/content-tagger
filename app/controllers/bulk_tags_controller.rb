class BulkTagsController < ApplicationController
  def new
    render :new, locals: {
      search_results: EmptySearchResponse.new,
      query: ''
    }
  end

  def results
    render :new, locals: { search_results: search_response, query: query }
  end

private

  def search_response
    @search_response ||= BulkTagging::Search.call(query: query, page: page)
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
