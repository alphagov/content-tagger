module Facets
  class FacetGroupPresenter < BasePresenter
    def name
      details["name"]
    end

    def description
      details["description"]
    end

    def state
      raw_data["publication_state"]
    end

    def facets
      expanded_links.fetch("facets", []).map do |facet_data|
        Facets::FacetPresenter.new(facet_data)
      end
    end

    def grouped_facet_values
      facets.map do |f|
        [f.title, f.facet_values.map { |fv| [fv.label, fv.content_id] }]
      end
    end

  private

    def expanded_links
      raw_data.fetch("expanded_links", {})
    end
  end
end
