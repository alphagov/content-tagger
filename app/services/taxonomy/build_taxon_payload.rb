module Taxonomy
  class BuildTaxonPayload
    def initialize(taxon)
      @taxon = taxon
    end

    def self.build(taxon:)
      new(taxon).build
    end

    def build
      {
        base_path: base_path,
        document_type: 'taxon',
        schema_name: 'taxon',
        title: title,
        description: description,
        publishing_app: 'content-tagger',
        rendering_app: 'collections',
        public_updated_at: Time.now.iso8601,
        locale: 'en',
        details: {
          internal_name: internal_name,
          notes_for_editors: notes_for_editors,
        },
        routes: [
          { path: base_path, type: "exact" },
        ]
      }
    end

  private

    attr_reader :taxon
    delegate(
      :base_path, :title, :description, :internal_name, :notes_for_editors,
      to: :taxon
    )
  end
end
