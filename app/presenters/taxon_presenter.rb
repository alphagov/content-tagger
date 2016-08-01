class TaxonPresenter
  def initialize(taxon)
    @taxon = taxon
  end

  def payload
    {
      base_path: base_path,
      document_type: 'taxon',
      schema_name: 'taxon',
      title: title,
      publishing_app: 'content-tagger',
      rendering_app: 'collections',
      public_updated_at: Time.now.iso8601,
      locale: 'en',
      details: {},
      routes: [
        { path: base_path, type: "exact" },
      ]
    }
  end

private

  attr_reader :taxon
  delegate :base_path, :title, to: :taxon
end
