module AlphaTaxonomy
  class TaxonPresenter
    attr_accessor :title, :slug

    def initialize(title:)
      @title = title
      validate_title
      @slug = title.parameterize
    end

    def present
      {
        base_path: base_path,
        document_type: "taxon",
        schema_name: "taxon",
        title: @title,
        # FIXME: We're stating that the publishing app is collections-publisher as
        # that's where taxons are currently being edited. That functionality
        # and the bulk import/mapping logic contained in this app will be merged
        # at some point once we figure out the best place for everything taxonomy-
        # related. Once that happens, the publishing_app for taxons may change.
        publishing_app: 'collections-publisher',
        rendering_app: 'collections',
        public_updated_at: DateTime.current.iso8601,
        locale: "en",
        details: {},
        routes: [
          { path: base_path, type: "exact" },
        ]
      }
    end

    # For now, create taxons at the 'alpha-taxons' base path. We may eventually
    # switch to using /taxons, but the naming below emphasises that these are
    # temporary and subject to change.
    def base_path
      @slug.gsub!(%r(^\/{1,}), '') # remove any leading slashes
      "/alpha-taxonomy/#{@slug}"
    end

  private

    def validate_title
      raise ArgumentError, "Title cannot be blank" if @title.blank?
    end
  end
end
