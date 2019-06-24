module Taxonomy
  class TaxonsWithContentCount
    def initialize(root_taxon)
      @root_taxon = root_taxon
    end

    def nested_tree
      @nested_tree ||= process_linked_content_item_tree(
        GovukTaxonomyHelpers::LinkedContentItem.from_content_id(
          content_id: @root_taxon.content_id,
          publishing_api: Services.publishing_api
        )
      )
    end

    def max_size
      @max_size ||= begin
        max_size_in_tree = lambda do |taxon|
          if taxon[:children].blank?
            taxon[:size]
          else
            [
              taxon[:children].map(&max_size_in_tree).max,
              taxon[:size]
            ].max
          end
        end

        max_size_in_tree.call(nested_tree)
      end
    end

  private

    def process_linked_content_item_tree(linked_content_item)
      {
        name: linked_content_item.title,
        content_id: linked_content_item.content_id,
        size: tagged_pages_count_by_content_id[linked_content_item.content_id] || 0,
        children: linked_content_item.children.map do |child_linked_content_item|
          process_linked_content_item_tree(child_linked_content_item)
        end
      }
    end

    # Returns a hash of taxon content_ids and the number of pages tagged to the
    # taxon, scope to the current root taxon.
    def tagged_pages_count_by_content_id
      @tagged_pages_count_by_content_id ||= begin
        search_result = Services.search_api.search(
          filter_part_of_taxonomy_tree: @root_taxon.content_id,
          facet_taxons: 1_000, # We have to specify a number,
          count: 0,
          debug: 'include_withdrawn',
        )

        # Search API will return a pretty odd datastructure for this query:
        # https://www.gov.uk/api/search.json?count=0&facet_taxons=1000
        search_result["facets"]["taxons"]["options"].each_with_object({}) do |o, h|
          content_id = o["value"]["slug"]
          document_count = o["documents"]

          h[content_id] = document_count
        end
      end
    end
  end
end
