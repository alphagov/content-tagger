require 'csv'

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
          row << node.depth
          row << node.content_item_count
          row << node.content_item_count_for_all_descendants
          row << node.coarseness
          row << node.percentage_of_content_compared_to_siblings
          csv << row
        end
      end
    end
  end
end



module GovukTaxonomyHelpers
  class LinkedContentItem

    def content_item_count
      content_item_counts[content_id].to_i
    end

    def content_item_count_for_all_descendants
      @content_item_count_for_all_descendants ||= begin
        content_item_count + descendants.inject(0) { |sum, child_taxon| sum + child_taxon.content_item_count_for_all_descendants.to_i }
      end
    end

    def coarseness
      return depth unless descendants.any?

      total_depth_of_children = descendants.inject(0) { |sum, child_taxon| sum + child_taxon.depth.to_i }
      content_item_count_for_all_descendants.to_f / total_depth_of_children.to_f
    end

    def percentage_of_content_compared_to_siblings
      if immediate_ancestor
        return 0 unless immediate_ancestor.content_item_count_for_all_descendants > 0

        (content_item_count_for_all_descendants.to_f / immediate_ancestor.content_item_count_for_all_descendants.to_f)
      end
    end

    def immediate_ancestor
      @immediate_ancestor ||= begin
        ancestors.last
      end
    end

    private

    def content_item_counts
      @content_item_counts ||= begin
        params = {
            count: 0,
            facet_taxons: 4000
        }
        results = Services.search_api.search(params).to_hash
        results['facets']['taxons']['options'].each_with_object({}) do |option, taxonomy_tree_counts|
          taxonomy_tree_counts[option['value']['slug']] = option['documents']
        end
      end
    end
  end
end
