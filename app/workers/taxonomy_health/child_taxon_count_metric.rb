module TaxonomyHealth
  class ChildTaxonCountMetric
    include Sidekiq::Worker
    include ActionView::Helpers::TextHelper

    def perform(arguments)
      maximum = arguments.symbolize_keys[:maximum]
      minimum = arguments.symbolize_keys[:minimum] || 0

      taxonomy = Taxonomy::ExpandedTaxonomy
                   .new(GovukTaxonomy::ROOT_CONTENT_ID)
                   .build.child_expansion

      taxonomy.tree.each do |linked_content_item|
        children_count = linked_content_item.children.count

        if children_count > maximum
          message = "Taxon has #{pluralize(children_count, 'child')}, "\
                    "which exceeds the maximum of #{maximum}"

          create_health_warning(linked_content_item, message, children_count)
        elsif children_count != 0 && children_count < minimum
          message = "Taxon has #{pluralize(children_count, 'child')}, "\
                    "which is fewer than the minimum of #{minimum}"

          create_health_warning(linked_content_item, message, children_count)
        end
      end
    end

  private

    def create_health_warning(linked_content_item, message, children_count)
      Taxonomy::HealthWarning.create(
        content_id: linked_content_item.content_id,
        title: linked_content_item.title,
        internal_name: linked_content_item.internal_name,
        path: linked_content_item.base_path,
        metric: self.class.to_s,
        value: children_count,
        message: message
      )
    end
  end
end
