module Taxonomy
  class BuildTaxon
    attr_reader :content_id

    class TaxonNotFoundError < StandardError; end

    def initialize(content_id:)
      @content_id = content_id
    end

    def self.call(content_id:)
      new(content_id: content_id).build
    end

    def build
      Taxon.new(
        content_id: content_id,
        title: content_item["title"],
        description: content_item["description"],
        base_path: content_item["base_path"],
        publication_state: content_item['publication_state'],
        internal_name: content_item['details']['internal_name'],
        notes_for_editors: content_item['details']['notes_for_editors'],
        parent_taxons: content_item.dig("links", "parent_taxons") || [],
      )
    end

  private

    def content_item
      @content_item ||= Services.publishing_api.get_content!(content_id)
    rescue GdsApi::HTTPNotFound => e
      raise(TaxonNotFoundError, e.message)
    end
  end
end
