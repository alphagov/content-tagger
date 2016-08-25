class ExportTaxonsController < ApplicationController
  def create
    respond_to do |format|
      format.csv { send_data exporter.data, filename: exporter.filename }
    end
  end

private

  def exporter
    @exporter ||= Taxonomy::Exporter.new(content_ids)
  end

  def content_ids
    params[:content_ids]
  end
end
