module LegacyTaxonomy
  module Client
    class SearchApi
      def self.content_ids_tagged_to_browse_page(taxon_content_id)
        tagged = Services.search.search(
          fields: %w(content_id),
          filter_mainstream_browse_page_content_ids: [taxon_content_id],
          count: 1000
        )

        tagged["results"]
          .map { |result| result['content_id'] }
          .compact
      end
    end
  end
end
