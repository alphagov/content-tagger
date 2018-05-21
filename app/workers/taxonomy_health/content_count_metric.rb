module TaxonomyHealth
  class ContentCountMetric
    include Sidekiq::Worker

    def perform(arguments)
      maximum = arguments.symbolize_keys[:maximum]
      taxonomy = Taxonomy::ExpandedTaxonomy.new(GovukTaxonomy::ROOT_CONTENT_ID).build.child_expansion
      taxon_counts = taxonomy.tree.map do |linked_content_item|
        { linked_content_item: linked_content_item, count: Taxonomy::ContentCounter.count(linked_content_item.content_id) }
      end
      taxon_counts.select { |item| item[:count] > maximum }.each do |item|
        linked_content_item = item[:linked_content_item]
        Taxonomy::HealthWarning.create(content_id: linked_content_item.content_id,
                                       title: linked_content_item.title,
                                       internal_name: linked_content_item.internal_name,
                                       path: linked_content_item.base_path,
                                       metric: self.class.to_s,
                                       message: "Taxon has #{item[:count]} content items, which exceeds the maximum of #{maximum}")
      end
    end
  end
end
