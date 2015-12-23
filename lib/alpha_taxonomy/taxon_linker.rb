require "csv"

module AlphaTaxonomy
  class TaxonLinker
    def run!
      ImportFile.new.grouped_mappings.each do |base_path, taxon_titles|
        taxon_content_ids = taxon_titles.map do |taxon_title|
          taxon_base_path = TaxonPresenter.new(title: taxon_title).base_path
          taxon_content_item = Services.content_store.content_item!(taxon_base_path)
          taxon_content_item["content_id"]
        end
        target_content_item = Services.content_store.content_item!(base_path)

        Services.publishing_api.put_links(
          target_content_item["content_id"],
          links: {
            alpha_taxons: taxon_content_ids
          }
        )
      end
    end
  end
end
