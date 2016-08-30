class TaxonomiesController < ApplicationController
  def show
    taxon_content_id = params[:content_id]
    @taxonomy = ExpandedTaxonomy.new(taxon_content_id).build
  end
end
