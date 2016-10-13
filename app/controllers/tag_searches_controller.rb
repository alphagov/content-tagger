class TagSearchesController < ApplicationController
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
    params[:tag_search][:query]
  end

  def search_params
    params.require(:tag_search).permit(:query)
  end
end
