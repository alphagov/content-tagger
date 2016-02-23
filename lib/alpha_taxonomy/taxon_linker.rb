require "csv"

module AlphaTaxonomy
  class TaxonLinker
    class TaxonNotInContentStoreError < StandardError; end

    def initialize(logger: Logger.new(STDOUT))
      @log = logger
      @errors = []
    end

    def run!
      ImportFile.new.grouped_mappings.each do |base_path, taxon_titles|
        @log.info "BEGIN mapping for #{base_path}"
        taxon_content_ids = find_content_ids_for(taxon_titles)
        @log.info "Content IDs are: #{taxon_content_ids}"
        content_item_id = fetch_content_item_id_with(base_path)
        attempt_content_item_update(content_item_id, taxon_content_ids)
        @log.info "=============================================="
        @log.info ""
      end

      @errors.each { |err| @log.error err } if @errors.present?
    end

    def attempt_content_item_update(content_item_id, taxon_content_ids)
      if content_item_id.blank?
        @log.info "No content ID found!"
      else
        @log.info "Content ID is #{content_item_id}"
        put_links_response = Services.publishing_api.put_links(
          content_item_id,
          links: {
            alpha_taxons: taxon_content_ids
          }
        )

        @log.info "Publishing API 'put' complete, response code: #{put_links_response.code}"
      end
    end

  private

    def report_error(error_message)
      @errors << error_message
    end

    def all_taxons
      @all_taxons ||= Services.publishing_api.get_content_items(
        content_format: 'taxon', fields: %i(title base_path content_id)
      ).sort_by { |taxon| taxon["title"] }
    end

    def find_content_ids_for(taxon_titles)
      @log.info "Determining content IDs for taxons..."
      content_id_list = taxon_titles.map do |taxon_title|
        # Find existing taxon by a base path derived from the taxon title
        taxon_content_item = all_taxons.find do |taxon|
          taxon.fetch("base_path") == TaxonPresenter.new(title: taxon_title).base_path
        end

        if taxon_content_item
          taxon_content_item["content_id"]
        else
          raise TaxonNotInContentStoreError, "Use TaxonCreator#run! to ensure all taxons have been created"
        end
      end

      # Ensure the list is unique, in case we had any duplicate mappings in
      # the import file
      content_id_list.uniq
    end

    def fetch_content_item_id_with(base_path)
      @log.info "Fetching content ID for base path above..."
      content_item = Services.live_content_store.content_item(base_path)
      return content_item.content_id if content_item.present?
      report_error("No content item found at #{base_path}")
      nil
    rescue
      report_error("Error fetching content id for #{base_path}: #{e}, Backtrace: #{e.backtrace.join("\n")}")
    end
  end
end
