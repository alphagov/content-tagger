module BrexitTaxon
  BREXIT_TAXON_CONTENT_ID = "d6c2de5d-ef90-45d1-82d4-5f2438369eea".freeze

  def brexit_taxon?(content_id)
    content_id == BREXIT_TAXON_CONTENT_ID
  end
end
