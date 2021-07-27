require_relative "../support/google_sheet_helper"

FactoryBot.define do
  factory :tagging_spreadsheet, class: BulkTagging::TaggingSpreadsheet do
    url { GoogleSheetHelper.google_sheet_url(key: "mykey", gid: "mygid") }
    user_uid { SecureRandom.uuid }
    state { "uploaded" }
  end
end
