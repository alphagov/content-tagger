require "csv"

module Taxonomy
  class CsvTreePresenter
    def initialize(tree)
      @tree = tree
    end

    def present
      CSV.generate do |csv|
        @tree.each do |node|
          row = [node.title]
          node.depth.times { row.unshift nil }
          row << get_count(node.content_id)
          csv << row
        end
      end
    end

  private

    def get_count(content_id)
      taxonomy_tree_counts[content_id]
    end

    def taxonomy_tree_counts
      @taxonomy_tree_counts ||= begin
        params = {
          count: 0,
          facet_taxons: 4000,
        }
        results = Services.search_api.search(params).to_hash
        results.dig("facets", "taxons", "options").each_with_object({}) do |option, taxon_content_count|
          taxon_content_count[option["value"]["slug"]] = option["documents"]
        end
      end
    end
  end
end
