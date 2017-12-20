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
        non_guidance = GdsApi::Rummager.new(Plek.find('rummager')).search(
          start: 0,
          filter_taxons: content_id,
          reject_navigation_document_supertype: 'guidance',
          count: 1,
        )['total']
        details[content_id]["non_guidance"] = non_guidance

        guidance = GdsApi::Rummager.new(Plek.find('rummager')).search(
          start: 0,
          filter_taxons: content_id,
          filter_navigation_document_supertype: 'guidance',
          count: 1,
        )['total']
        details[content_id]["guidance"] = guidance
      end

      details.each_key do |content_id|
        resp = Services.publishing_api.get_content(content_id)
        details[content_id]["title"] = resp["title"]
        details[content_id]["base_path"] = resp["base_path"]
      end

      headers = ['Content ID', 'Title', 'Link', 'Guidance Documents', 'Non-Guidance Documents', 'Total no. of documents']
      CSV do |csv|
        csv << headers
        details.each_key do |content_id|
          csv << [
            content_id,
            details[content_id]["title"],
            details[content_id]["base_path"],
            details[content_id]["guidance"],
            details[content_id]["non_guidance"],
            details[content_id]["document_count"]
          ]
        end
      end
    end
  end
end
