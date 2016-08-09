class InitialTaggingImport
  include Sidekiq::Worker

  def perform(tagging_spreadsheet_id)
    tagging_spreadsheet = TaggingSpreadsheet.find(tagging_spreadsheet_id)
    errors = TagImporter::FetchRemoteData.new(tagging_spreadsheet).run

    if errors.any?
      tagging_spreadsheet.update_attributes!(state: "errored", error_message: errors.join("\n"))
    else
      tagging_spreadsheet.update_attributes!(state: "ready_to_import")
    end
  end
end
