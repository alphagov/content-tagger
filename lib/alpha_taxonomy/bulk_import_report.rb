module AlphaTaxonomy
  class BulkImportReport
    include AlphaTaxonomy::Helpers::ImportFileHelper

    def initialize(logger: Logger.new(STDOUT))
      @log = logger
    end

    def view
      check_import_file_is_present
      @no_alpha_taxon = []
      @no_content_item = []
      @updated = []

      grouped_mappings.each do |path, _taxon_titles|
        determine_update_state_of(path)
      end

      log_summary
    end

  private

    def grouped_mappings
      @grouped_mappings ||= ImportFile.new.grouped_mappings
    end

    def determine_update_state_of(path)
      content_item = Services.content_store.content_item(path)

      if content_item.blank?
        @no_content_item << { path: path }
        return
      end

      if content_item.links["alpha_taxons"].blank?
        @no_alpha_taxon << { path: path, cid: content_item.content_id }
      else
        @updated << { path: path, cid: content_item.content_id }
      end
    end

    def log_summary
      @log.info "BULK IMPORT SUMMARY"
      log_no_alpha_taxons
      log_no_content_items
      log_updated
      log_numbers
    end

    def log_numbers
      @log.info "Total #{@grouped_mappings.count}"
      @log.info "No alpha taxon:  #{@no_alpha_taxon.count}"
      @log.info "No content item found: #{@no_content_item.count}"
      @log.info "Updated: #{@updated.count}"
      @log.info "#{@no_alpha_taxon.count + @no_content_item.count + @updated.count} of #{@grouped_mappings.count} accounted for"
    end

    def log_no_alpha_taxons
      @log.info "************** No alpha taxon **************"
      @no_alpha_taxon.each do |bad_update|
        @log.info "#{bad_update[:cid]} - #{bad_update[:path]}"
      end
      @log.info ""
    end

    def log_no_content_items
      @log.info "************** No content item **************"
      @no_content_item.each do |bad_update|
        @log.info "#{bad_update[:path]}"
      end
      @log.info ""
    end

    def log_updated
      @log.info "************** Updated **************"
      @updated.each do |good_update|
        @log.info "#{good_update[:cid]} - #{good_update[:path]}"
      end
      @log.info ""
    end
  end
end
