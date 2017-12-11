require 'csv'

module Taxonomy
  class TaxonomyExport
    COLUMNS = %w[title description content_id base_path document_type].freeze

    def initialize(content_id)
      @content_id = content_id
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << COLUMNS
        tagged_content.each do |tagged_item|
          csv << tagged_item.slice(*COLUMNS)
        end
      end
    end

  private

    def tagged_content
      Services.publishing_api.get_linked_items(
        @content_id,
        link_type: 'taxons',
        fields: COLUMNS
      )
    end
  end
end
