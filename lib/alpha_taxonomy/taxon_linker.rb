require "csv"

module AlphaTaxonomy
  class TaxonLinker
    class TaxonNotInContentStoreError < StandardError; end

    def initialize(logger: Logger.new(STDOUT))
      @log = logger
      @errors = []
    end

    def run!
      grouped_mappings = ImportFile.new.grouped_mappings

      grouped_mappings.each do |base_path, taxon_titles|
        taxon_content_ids = find_content_ids_for(taxon_titles)
        target_content_item_id = fetch_content_item_id_with(base_path)

        next unless target_content_item_id.present?
        Services.publishing_api.put_links(
          target_content_item_id,
          links: {
            alpha_taxons: taxon_content_ids
          }
        )
      end

      @errors.each { |err| @log.error err } if @errors.present?
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
      taxon_titles.map do |taxon_title|
        taxon_content_item = all_taxons.find { |taxon| taxon["title"] == taxon_title }
        if taxon_content_item
          taxon_content_item["content_id"]
        else
          raise TaxonNotInContentStoreError, "Use TaxonCreator#run! to ensure all taxons have been created"
        end
      end
    end

    def fetch_content_item_id_with(base_path)
      lookup = ContentLookupForm.new(base_path: base_path)
      return lookup.content_id if lookup.valid?
      report_error("Error fetching content id for #{base_path}: #{lookup.errors[:base_path]}")
      nil
    end
  end
end
