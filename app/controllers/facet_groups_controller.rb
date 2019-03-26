class FacetGroupsController < ApplicationController
  def index
    results = Facets::RemoteFacetGroupsService.new.find_all

    @facet_groups = results.map do |result|
      Facets::FacetGroupPresenter.new(result)
    end
  end
end
