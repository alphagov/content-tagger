module GovukTaxonomyHelpers
  class PublishingApiResponse
    attr_accessor :linked_content_item

    # @param content_item [Hash] Publishing API `get_content` response hash
    # @param expanded_links [Hash] Publishing API `get_expanded_links` response hash
    def initialize(content_item:, expanded_links:)
      details = content_item["details"] || {}

      @linked_content_item = LinkedContentItem.new(
        title: content_item["title"],
        internal_name: details["internal_name"],
        content_id: content_item["content_id"],
        base_path: content_item["base_path"]
      )

      add_expanded_links(expanded_links)
    end

  private

    def add_expanded_links(expanded_links_response)
      child_taxons = expanded_links_response["expanded_links"]["child_taxons"]
      parent_taxons = expanded_links_response["expanded_links"]["parent_taxons"]
      taxons = expanded_links_response["expanded_links"]["taxons"]

      if !child_taxons.nil?
        child_taxons.each do |child|
          linked_content_item << parse_nested_child(child)
        end
      end

      if !parent_taxons.nil?
        # Assume no taxon has multiple parents
        single_parent = parent_taxons.first

        parse_nested_parent(single_parent) << linked_content_item
      end

      if !taxons.nil?
        taxons.each do |taxon|
          taxon_node = parse_nested_parent(taxon)
          linked_content_item.add_taxon(taxon_node)
        end
      end
    end

    def parse_nested_child(nested_item)
      details = nested_item["details"] || {}
      links = nested_item["links"] || {}

      nested_linked_content_item = LinkedContentItem.new(
        title: nested_item["title"],
        internal_name: details["internal_name"],
        content_id: nested_item["content_id"],
        base_path: nested_item["base_path"]
      )

      child_taxons = links["child_taxons"]

      if !child_taxons.nil?
        child_taxons.each do |child|
          nested_linked_content_item << parse_nested_child(child)
        end
      end

      nested_linked_content_item
    end

    def parse_nested_parent(nested_item)
      details = nested_item["details"] || {}
      links = nested_item["links"] || {}

      nested_linked_content_item = LinkedContentItem.new(
        title: nested_item["title"],
        internal_name: details["internal_name"],
        content_id: nested_item["content_id"],
        base_path: nested_item["base_path"]
      )

      parent_taxons = links["parent_taxons"]

      if !parent_taxons.nil?
        single_parent = parent_taxons.first
        parse_nested_parent(single_parent) << nested_linked_content_item
      end

      nested_linked_content_item
    end
  end
end
