class CopyTaxonsController < ApplicationController
  def index
    render :index, locals: { taxons: taxons }
  end

private

  def taxons
    Linkables.new.get_tags_of_type(:taxon)
  end
end
