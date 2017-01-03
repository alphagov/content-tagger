# TODO: put this safely into BulkTagging module
class InitialTaggingImport
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(tagging_spreadsheet_id)
    tagging_spreadsheet = BulkTagging::TaggingSpreadsheet.find(tagging_spreadsheet_id)
    errors = BulkTagging::FetchRemoteData.call(tagging_spreadsheet)

    if errors.any?
      tagging_spreadsheet.update_attributes!(state: "errored", error_message: errors.join("\n"))
    else
      tagging_spreadsheet.update_attributes!(state: "ready_to_import")
    end
  end
end
