module TaxonomyHealth
  class MaximumDepthMetric
    include Sidekiq::Worker

    DESCRIPTION = 'Taxon is too deep in the taxonomy'.freeze

    def perform(arguments)
      maximum_depth = arguments.symbolize_keys[:maximum_depth]

      taxonomy = Taxonomy::ExpandedTaxonomy
                   .new(GovukTaxonomy::ROOT_CONTENT_ID)
                   .build.child_expansion

      children_with_depth_exceeding(
        taxonomy,
        maximum_depth
      ).each do |linked_content_item|
        Taxonomy::HealthWarning.create(
          content_id: linked_content_item.content_id,
          title: linked_content_item.title,
          internal_name: linked_content_item.internal_name,
          path: linked_content_item.base_path,
          metric: self.class.to_s,
          message: "Taxon exceeds depth of #{maximum_depth}"
        )
      end
    end

  private

    def children_with_depth_exceeding(linked_content_item, maximum_depth, current_depth = 0)
      result = current_depth > maximum_depth ? [linked_content_item] : []
      result + linked_content_item.children.flat_map do |child|
        children_with_depth_exceeding(child, maximum_depth, current_depth + 1)
      end
    end
  end
end
