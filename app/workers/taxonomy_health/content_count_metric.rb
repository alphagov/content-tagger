module TaxonomyHealth
  class ContentCountMetric
    include Sidekiq::Worker

    DESCRIPTION = "Taxon has too much content tagged to it".freeze

    def perform(arguments)
      maximum = arguments.symbolize_keys[:maximum]
      taxonomy = Taxonomy::ExpandedTaxonomy
                   .new(GovukTaxonomy::ROOT_CONTENT_ID)
                   .build.child_expansion

      taxonomy.tree.each do |linked_content_item|
        content_count = Taxonomy::ContentCounter
                          .count(linked_content_item.content_id)

        next if content_count <= maximum

        Taxonomy::HealthWarning.create(
          content_id: linked_content_item.content_id,
          title: linked_content_item.title,
          internal_name: linked_content_item.internal_name,
          path: linked_content_item.base_path,
          metric: self.class.to_s,
          value: content_count,
          message: "Taxon has #{content_count} content items, "\
                   "which exceeds the maximum of #{maximum}",
        )
      end
    end
  end
end
