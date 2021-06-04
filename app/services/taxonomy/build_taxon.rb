module Taxonomy
  class BuildTaxon
    attr_reader :content_id

    class TaxonNotFoundError < StandardError; end

    class DocumentTypeError < StandardError; end

    def initialize(content_id:)
      @content_id = content_id
    end

    def self.call(content_id:)
      new(content_id: content_id).build
    end

    def build
      validate_taxon_response!

      Taxon.new(
        content_id: content_id,
        title: content_item["title"],
        description: content_item["description"],
        base_path: content_item["base_path"],
        publication_state: content_item["publication_state"],
        state_history: content_item["state_history"],
        phase: content_item["phase"],
        internal_name: content_item["details"]["internal_name"],
        notes_for_editors: content_item["details"]["notes_for_editors"],
        url_override: content_item["details"]["url_override"],
        parent_content_id: parent,
        associated_taxons: links["associated_taxons"],
        legacy_taxons: legacy_taxon_paths,
        redirect_to: content_item.dig("unpublishing", "alternative_path"),
        visible_to_departmental_editors: content_item.dig("details", "visible_to_departmental_editors"),
      )
    end

  private

    def parent
      links.dig("parent_taxons", 0) || links.dig("root_taxon", 0)
    end

    def content_item
      @content_item ||= Services.publishing_api.get_content(content_id)
    rescue GdsApi::HTTPNotFound => e
      raise(TaxonNotFoundError, e.message)
    end

    def validate_taxon_response!
      return if content_item["document_type"].in? %(homepage taxon)

      raise DocumentTypeError
    end

    def links
      @links ||= expanded_links.transform_values { |v| v.map { |h| h["content_id"] } }
    end

    def expanded_links
      @expanded_links ||= Services.publishing_api
          .get_expanded_links(content_id)
          .to_h
          .fetch("expanded_links", {})
    end

    def legacy_taxon_paths
      expanded_links.fetch("legacy_taxons", []).map { |v| v["base_path"] }
    end
  end
end
