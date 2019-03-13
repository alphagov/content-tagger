module Facets
  class FacetValuePresenter < BasePresenter
    def option_data
      {
        id: details["value"],
        text: details["label"],
      }
    end
  end
end
