module Taxonomy
  class TaxonBuilder
    attr_reader :content_id

    def initialize(content_id:)
      @content_id = content_id
    end

    def self.build(content_id:)
      new(content_id: content_id).build
    end

    def build
      Taxon.new(
        content_id: content_id,
        title: content_item["title"],
        base_path: content_item["base_path"],
        parent_taxons: parent_taxons
      )
    end

  private

    def parent_taxons
      links["parent_taxons"] || []
    end

    def content_item
      @content_item ||= Services.publishing_api.get_content(content_id)
    end

    def links
      @links ||= Services.publishing_api.get_links(content_id)['links'].to_h
    end
  end
end
