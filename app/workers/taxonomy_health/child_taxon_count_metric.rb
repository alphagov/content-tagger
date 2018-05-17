module TaxonomyHealth
  class ChildTaxonCountMetric
    include Sidekiq::Worker
    include ActionView::Helpers::TextHelper

    def perform(arguments)
      maximum = arguments.symbolize_keys[:maximum]
      minimum = arguments.symbolize_keys[:minimum] || 0
      taxonomy = Taxonomy::ExpandedTaxonomy.new(GovukTaxonomy::ROOT_CONTENT_ID).build.child_expansion
      taxon_counts = taxonomy.tree.map do |linked_content_item|
        { linked_content_item: linked_content_item, count: linked_content_item.children.count }
      end
      taxon_counts.select { |item| item[:count] > maximum }.each do |item|
        message = "Taxon has #{pluralize(item[:count], 'child')}, which exceeds the maximum of #{maximum}"
        create_health_warning(item[:linked_content_item], message)
      end
      taxon_counts.select { |item| item[:count].positive? && item[:count] < minimum }.each do |item|
        message = "Taxon has #{pluralize(item[:count], 'child')}, which is fewer than the minimum of #{minimum}"
        create_health_warning(item[:linked_content_item], message)
      end
    end

  private

    def create_health_warning(linked_content_item, message)
      Taxonomy::HealthWarning.create(content_id: linked_content_item.content_id,
                                     title: linked_content_item.title,
                                     internal_name: linked_content_item.internal_name,
                                     path: linked_content_item.base_path,
                                     metric: self.class.to_s,
                                     message: message)
    end
  end
end
