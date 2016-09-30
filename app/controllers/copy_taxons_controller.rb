class CopyTaxonsController < ApplicationController
  def index
    render :index, locals: { taxons: taxons }
  end

private

  def taxons
    Services.publishing_api.get_linkables(format: 'taxon')
  end
end
