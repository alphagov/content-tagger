require_relative '../support/google_sheet_helper.rb'

include GoogleSheetHelper

FactoryGirl.define do
  factory :tagging_spreadsheet do
    url google_sheet_url(key: 'mykey', gid: 'mygid')

    state 'uploaded'
  end
end
