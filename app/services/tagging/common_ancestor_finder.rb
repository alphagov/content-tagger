module Tagging
  class CommonAncestorFinder
    def self.call
      new.find_all
    end

    def find_all
      content_enum = Services.search_api.search_enum(
        { reject_content_store_document_type: Tagging.blacklisted_document_types,
          fields: %w[content_id title] },
        page_size: 100,
      )
      filtered_content_enum = content_enum.lazy.select { |c| c.key?("content_id") }
      all_results = filtered_content_enum.map do |content_hash|
        content_id = content_hash["content_id"]
        title = content_hash["title"]
        begin
          expanded_links_hash = Services.publishing_api.get_expanded_links(content_id).to_h
          {
            content_id: content_id,
            title: title,
            common_ancestors: find_common_ancestors(taxon_paths(expanded_links_hash)),
          }
        rescue GdsApi::HTTPNotFound
          {}
        rescue GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException, GdsApi::HTTPBadGateway
          retries ||= 0
          raise if retries >= 3

          retries += 1
          retry
        end
      end
      all_results.select { |result| result[:common_ancestors].present? }
    end

  private

    def taxon_paths(content_hash)
      taxon_path = lambda do |taxon_hash|
        return [] if taxon_hash.nil?

        taxon_path.call(taxon_hash.dig("links", "parent_taxons", 0) ||
                        taxon_hash.dig("links", "root_taxon", 0)).append(taxon_hash["content_id"])
      end

      taxon_hashes = content_hash.dig("expanded_links", "taxons") || []
      taxon_hashes.map do |taxon_hash|
        taxon_path.call(taxon_hash)
      end
    end

    # Finds the common ancestors from a list of paths of one or more trees
    # The paths are ordered from the root to leaf
    def find_common_ancestors(paths, common_ancestors = [])
      return common_ancestors if paths.empty?

      # Remove paths with a unique root - these cannot have common ancestors
      paths_grouped_by_root = paths.group_by(&:first)
      paths_with_common_root = paths_grouped_by_root.select { |_, v| v.length > 1 }.values.flatten(1)

      # Remaining paths with length one have a common ancestor, i.e. the common root
      paths_with_length_one = paths_with_common_root.select { |v| v.length == 1 }
      paths_with_length_greater_than_one = paths_with_common_root.select { |n| n.length > 1 }

      find_common_ancestors(paths_with_length_greater_than_one.map { |n| n[1..] }, common_ancestors + paths_with_length_one.flatten)
    end
  end
end
