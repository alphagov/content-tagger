class TagSearchesController < ApplicationController
  def new
    render :new, locals: { results: [], query: '' }
  end

  def results
    warning_about_multiple_pages

    render :new, locals: { results: search_response.results, query: query }
  end

private

  def warning_about_multiple_pages
    if search_response.multiple_pages?
      flash[:warning] = I18n.t('controllers.bulk_taggings.too_many_results')
    else
      flash.delete(:warning)
    end
  end

  def search_response
    @search_response ||= BulkTagging::Search.perform(query: query)
  end

  def query
    params[:collection_search][:query]
  end

  def search_params
    params.require(:collection_search).permit(:query)
  end
end
