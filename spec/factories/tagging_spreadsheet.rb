require_relative "../support/google_sheet_helper.rb"

include GoogleSheetHelper

FactoryBot.define do
  factory :tagging_spreadsheet, class: BulkTagging::TaggingSpreadsheet do
    url { google_sheet_url(key: "mykey", gid: "mygid") }
    user_uid { SecureRandom.uuid }
    state { "uploaded" }
  end
end
