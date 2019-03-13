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
      facets.map { |f| { id: f.key, text: f.title, children: f.facet_values.map(&:option_data) } }
    end

  private

    def expanded_links
      raw_data.fetch("expanded_links", {})
    end
  end
end
