class TaxonomiesController < ApplicationController
  def show
    taxon_content_id = params[:content_id]
    taxonomy = Taxonomy::ExpandedTaxonomy.new(taxon_content_id).build

    respond_to do |format|
      format.csv do
        send_data(
          Taxonomy::CsvTreePresenter.new(taxonomy.child_expansion).present,
          filename: "#{taxonomy.root_node.title}.csv",
        )
      end
    end
  end
end
