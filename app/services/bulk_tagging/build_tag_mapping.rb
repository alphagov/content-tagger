module BulkTagging
  class BuildTagMapping
    attr_reader :taxon, :content_base_path

    def initialize(taxon:, content_base_path:)
      @taxon = taxon
      @content_base_path = content_base_path
    end

    def self.call(taxon:, content_base_path:)
      new(taxon: taxon, content_base_path: content_base_path).call
    end

    def call
      TagMapping.new(
        content_base_path: content_base_path,
        link_title: taxon.title,
        link_content_id: taxon.content_id,
        link_type: "taxons",
        state: "ready_to_tag",
      )
    end
  end
end
