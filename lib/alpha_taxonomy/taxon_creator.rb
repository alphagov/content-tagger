require 'csv'

module AlphaTaxonomy
  class TaxonCreator
    include AlphaTaxonomy::Helpers::ImportFileHelper

    def initialize(logger: Logger.new(STDOUT))
      @log = logger
    end

    def run!
      check_import_file_is_present
      import_file_titles.each do |taxon_title|
        @log.info "BEGIN processing taxon: #{taxon_title}"
        find_or_create_taxon(title: taxon_title)
        @log.info "=============================================="
        @log.info ""
      end
    end

    def find_or_create_taxon(title:)
      taxon_presenter = TaxonPresenter.new(title: title)
      existing = existing_taxons.find do |existing_taxon|
        existing_taxon["base_path"] == taxon_presenter.base_path
      end

      if existing.present?
        @log.info "Taxon with base path #{taxon_presenter.base_path} already exists!"
      else
        create_new_taxon(presented_payload: taxon_presenter.present)
      end
    end

  private

    def mappings_from_import_file
      CSV.read(
        AlphaTaxonomy::ImportFile.location, col_sep: "\t", headers: true
      )
    end

    def import_file_titles
      @import_file_titles ||= mappings_from_import_file.map { |mapping| mapping.fetch("taxon_title") }.uniq
    end

    def existing_taxons
      Services.publishing_api.get_linkables(
        document_type: 'taxon',
      ).to_a
    end

    def create_new_taxon(presented_payload:)
      content_id = SecureRandom.uuid
      put_response = Services.publishing_api.put_content(content_id, presented_payload)
      @log.info "Publishing API 'put' complete, content_id: #{content_id}, response code: #{put_response.code}"
      publish_response = Services.publishing_api.publish(content_id, "major")
      @log.info "Publishing API 'publish' complete, response code: #{publish_response.code}"
    end
  end
end
