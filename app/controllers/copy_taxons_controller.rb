class CopyTaxonsController < ApplicationController
  def index
    render :index, locals: { taxons: taxons }
  end

private

  def taxons
    @taxons ||= Taxonomy::TaxonFetcher.new.taxons
  end
end
