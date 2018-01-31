require 'csv'

module Taxonomy
  class TaxonsExport
    COLUMNS = %w[title description content_id base_path].freeze

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << COLUMNS
        taxons.each do |taxon|
          csv << taxon.to_h.slice(*COLUMNS)
        end
      end
    end

    puts "hello"
    puts Services.publishing_api.get_content_items(document_type: 'taxon', per_page: 1000)["results"]

  private

    def taxons
      Services.publishing_api.get_content_items(
        document_type: 'taxon',
        per_page: 1000,
      )["results"]
    end
  end
end
