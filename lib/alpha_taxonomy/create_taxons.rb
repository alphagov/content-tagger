require 'csv'

module AlphaTaxonomy
  class CreateTaxons
    class MissingImportFileError < StandardError; end

    def run!
      check_import_file_is_present

      import_file_titles = mappings_from_import_file.map { |mapping| mapping.fetch("taxon_title") }
      import_file_titles.uniq!

      import_file_titles.each do |taxon_title|
        taxon_presenter = TaxonPresenter.new(title: taxon_title)
        existing = existing_taxons.find do |existing_taxon|
          existing_taxon["base_path"] == taxon_presenter.base_path
        end

        next if existing.present?
        create_new_taxon(presented_payload: taxon_presenter.present)
      end
    end

private
    def check_import_file_is_present
      unless File.exist? AlphaTaxonomy::SheetDownloader.cache_location
        raise MissingImportFileError
      end
    end

    def mappings_from_import_file
      CSV.read(
        AlphaTaxonomy::SheetDownloader.cache_location, col_sep: "\t", headers: true
      )
    end

    def existing_taxons
      @existing_taxons ||= Services.publishing_api.get_content_items(
        content_format: 'taxon',
        fields: %i(title base_path content_id details)
      )
    end

    def create_new_taxon(presented_payload:)
      content_id = SecureRandom.uuid
      Services.publishing_api.put_content(
        content_id,
        presented_payload
      )
    end
  end
end
