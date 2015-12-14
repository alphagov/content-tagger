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
        format: "taxon",
        title: @title,
        publishing_app: 'content-tagger',
        rendering_app: 'collections',
        public_updated_at: DateTime.current.to_s,
        locale: "en",
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
