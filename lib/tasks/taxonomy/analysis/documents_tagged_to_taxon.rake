require 'gds_api/rummager'
require 'csv'

namespace :taxonomy do
  namespace :analysis do
    desc "Produces a CSV list that counts how many documents are tagged to a taxon"
    task count_documents_per_taxon: :environment do
      results = GdsApi::Rummager.new(Plek.find('rummager')).search(
        start: 0,
        facet_taxons: 100_000,
      )['facets']['taxons']['options']

      details = {}

      results.each do |hash|
        content_id = hash['value']['slug']
        document_count = hash['documents']
        details[content_id] = {
          "document_count" => document_count
        }
      end

      details.keys.each do |content_id|
        resp = Services.publishing_api.get_content(content_id)
        details[content_id]["title"] = resp["title"]
        details[content_id]["base_path"] = resp["base_path"]
      end

      headers = ['Content ID', 'Title', 'Link', 'Number of documents']
      CSV do |csv|
        csv << headers
        details.keys.each do |content_id|
          csv << [
            content_id,
            details[content_id]["title"],
            details[content_id]["base_path"],
            details[content_id]["document_count"]
          ]
        end
      end
    end
  end
end
