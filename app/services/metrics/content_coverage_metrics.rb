module Metrics
  class ContentCoverageMetrics
    def record_all
      all_govuk_items
      average_tagging_depth
      tagged_items_in_scope
      untagged_items_in_scope
    end

    def all_govuk_items
      gauge("all_govuk_items", all_govuk_items_count)
    end

    def average_tagging_depth
      gauge("items_in_scope", items_in_scope_count)
    end

    def tagged_items_in_scope
      gauge("tagged_items_in_scope", tagged_items_in_scope_count)
    end

    def untagged_items_in_scope
      gauge(
        "untagged_items_in_scope",
        items_in_scope_count - tagged_items_in_scope_count
      )
    end

  private

    def all_govuk_items_count
      @_items_count ||= Services.rummager.search(
        count: 0,
        debug: 'include_withdrawn'
      ).to_h.fetch("total")
    end

    def items_in_scope_count
      @_items_in_scope_count ||= Services.rummager.search(
        count: 0,
        reject_content_store_document_type: blacklisted_document_types,
        debug: 'include_withdrawn'
      ).to_h.fetch("total")
    end

    def tagged_items_in_scope_count
      @_tagged_items_in_scope_count ||= Services.rummager.search(
        count: 0,
        filter_part_of_taxonomy_tree: root_taxon_content_ids,
        reject_content_store_document_type: blacklisted_document_types,
        debug: 'include_withdrawn'
      ).to_h.fetch("total")
    end

    def root_taxon_content_ids
      GovukTaxonomy::Branches.new.all.map do |root_taxon|
        root_taxon['content_id']
      end
    end

    def gauge(stat, value)
      Metrics.statsd.gauge(stat, value)
    end

    def blacklisted_document_types
      @_blacklisted_document_types ||=
        config_for(:blacklisted_document_types)['document_types']
    end
  end
end
