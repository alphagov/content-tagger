module Taxonomy
  class TaxonomySize
    attr_reader :root_taxon

    # @param [ContentItem] root_taxon
    def initialize(root_taxon)
      @root_taxon = root_taxon
    end

    def nested_tree
      @_nested_tree ||= begin
        {
          name: root_taxon.title,
          content_id: root_taxon.content_id,
          size: tagged_pages_count_by_content_id[root_taxon.content_id] || 0,
          children: add_children_recursively(taxonomy_tree),
        }
      end
    end
    end

  private

    def add_children_recursively(taxon)
      child_taxons = (taxon["expanded_links"] || taxon["links"]).dig("child_taxons").to_a

      child_taxons.map do |child_taxon|
        recursed = add_children_recursively(child_taxon)
        count = tagged_pages_count_by_content_id[child_taxon["content_id"]] || 0

        out = {
          name: child_taxon["title"],
          content_id: child_taxon["content_id"],
          size: count,
        }

        out[:children] = recursed if recursed.any?

        out
      end
    end

    # Returns a hash of taxon content_ids and the number of pages tagged to the
    # taxon, scope to the current root taxon.
    def tagged_pages_count_by_content_id
      @tagged_pages_count_by_content_id ||= begin
        search_result = Services.rummager.search(
          filter_part_of_taxonomy_tree: root_taxon.content_id,
          facet_taxons: 1_000, # We have to specify a number,
          count: 0,
        )

        # Rummager will return a pretty odd datastructure for this query:
        # https://www.gov.uk/api/search.json?count=0&facet_taxons=1000
        search_result["facets"]["taxons"]["options"].each_with_object({}) do |o, h|
          content_id = o["value"]["slug"]
          document_count = o["documents"]

          h[content_id] = document_count
        end
      end
    end

    def taxonomy_tree
      Services.publishing_api.get_expanded_links(root_taxon.content_id).to_h
    end
  end
end
