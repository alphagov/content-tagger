class TaxonomiesController < ApplicationController
  def show
    taxon_content_id = params[:content_id]
    @taxonomy = ExpandedTaxonomy.new(taxon_content_id).build

    respond_to do |format|
      format.csv do
        send_data(
          CsvTreePresenter.new(@taxonomy.child_expansion).present,
          filename: @taxonomy.root_node.content_item.title + ".csv"
        )
      end
    end
  end
end
