require 'csv'

module Taxonomy
  class Exporter
    attr_reader :content_ids

    def initialize(content_ids)
      @content_ids = content_ids
    end

    def filename
      "content-id-lookup-#{Time.current.to_formatted_s(:number)}.csv"
    end

    def data
      CSV.generate(headers: true) do |csv|
        csv << title_headers

        filtered_taxons.each do |taxon|
          csv << [taxon.title, taxon.content_id, taxon.link_type]
        end
      end
    end

  private

    def content_ids
      @content_ids ||= []
    end

    def title_headers
      ['Title', 'Taxon Content ID', 'Link Type']
    end

    def filtered_taxons
      taxons.select { |taxon| content_ids.include?(taxon.content_id) }
    end

    def taxons
      @taxons ||=
        Taxonomy::TaxonFetcher.new.taxons.map { |taxon| Taxon.new(taxon) }
    end
  end
end
