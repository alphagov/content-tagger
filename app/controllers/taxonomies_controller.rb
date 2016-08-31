class TaxonomiesController < ApplicationController
  def show
    taxon_content_id = params[:content_id]
    @taxonomy = ExpandedTaxonomy.new(taxon_content_id).build

    respond_to do |format|
      format.html

      format.csv do
        send_data(
          CsvTreePresenter.new(@taxonomy).present,
          filename: @taxonomy.tree.first.title + ".csv"
        )
      end
    end
  end
end
