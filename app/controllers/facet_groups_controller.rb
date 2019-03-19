class FacetGroupsController < ApplicationController
  def index
    results = Facets::RemoteFacetGroupsService.new.find_all

    @facet_groups = results.map do |result|
      Facets::FacetGroupPresenter.new(result)
    end
  end

  def show
    result = Facets::RemoteFacetGroupsService.new.find(params[:facet_group_content_id])
    @facet_group = Facets::FacetGroupPresenter.new(result)
  end
end
