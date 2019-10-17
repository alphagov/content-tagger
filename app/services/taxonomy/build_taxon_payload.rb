module Taxonomy
  class BuildTaxonPayload
    def initialize(taxon)
      @taxon = taxon
    end

    def self.call(taxon:, locale: "en")
      new(taxon).build(locale)
    end

    def build(locale)
      {
        base_path: path(locale),
        document_type: "taxon",
        schema_name: "taxon",
        title: title,
        description: locale == "en" ? description : nil,
        publishing_app: "content-tagger",
        rendering_app: "collections",
        public_updated_at: Time.now.iso8601,
        locale: locale,
        details: {
          internal_name: internal_name,
          notes_for_editors: notes_for_editors,
          visible_to_departmental_editors: visible_to_departmental_editors,
        },
        routes: [
          { path: path(locale), type: "exact" },
        ],
        update_type: "major",
        phase: phase,
      }
    end

  private

    def path(locale)
      @path ||= locale == "en" ? base_path : base_path + ".#{locale}"
    end

    attr_reader :taxon
    delegate(
      :base_path, :title, :description, :internal_name, :notes_for_editors,
      :phase, :visible_to_departmental_editors,
      to: :taxon
    )
  end
end
