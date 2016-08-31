class CopyTaxonsController < ApplicationController
  def index
    taxons = taxon_fetcher.taxons.map { |taxon| Taxon.new(taxon) }
    render :index, locals: { taxons: taxons }
  end

private

  def taxon_fetcher
    @taxon_fetcher ||= Taxonomy::TaxonFetcher.new
  end
end
