class CopyTaxonsController < ApplicationController
  def index
    render :index, locals: { taxons: taxons }
  end

private

  def taxons
    @taxons ||= Taxonomy::FetchAllTaxons.new.taxons
  end
end
