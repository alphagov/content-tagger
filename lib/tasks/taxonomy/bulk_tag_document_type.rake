require 'csv'
require_relative Rails.root.join('lib', 'tagged_content_exporter')

namespace :taxonomy do
  desc <<-DESC
    Bulk tag all content items with a given document type to one taxon.
    A JSON representation of the output is sent to STDOUT and can be
    redirected to a file if needed.
  DESC
  task :bulk_tag_document_type, %i[document_type taxon_content_id] => :environment do |_, args|
    document_type = args[:document_type]
    taxon_content_id = args[:taxon_content_id]

    results = BulkTagging::DocumentTypeTagger.call(taxon_content_id: taxon_content_id, document_type: document_type).map do |result|
      STDERR.puts(result)
      result
    end

    puts results.to_json
  end
end
