class CopyTaxonsController < ApplicationController
  def index
    render :index, locals: { taxons: taxons }
  end

private

  def taxons
    @taxons ||= RemoteTaxons.new.all
  end
end
