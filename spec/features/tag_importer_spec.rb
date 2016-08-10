require "rails_helper"

RSpec.feature "Tag importer", type: :feature do
  require 'gds_api/test_helpers/publishing_api_v2'
  include GdsApi::TestHelpers::PublishingApiV2
  include GoogleSheetHelper

  before do
    Sidekiq::Testing.inline!
  end

  scenario "Importing tags" do
    given_tagging_data_is_present_in_a_google_spreadsheet
    when_i_provide_the_public_uri_of_this_spreadsheet
    then_i_can_preview_which_taggings_will_be_imported
    and_confirming_this_will_import_taggings
  end

  scenario "Reimporting tags" do
    given_some_imported_tags
    when_i_update_the_spreadsheet
    and_refetch_the_tags
    then_i_should_see_an_updated_preview
  end

  scenario "The spreadsheet contains bad data" do
    given_no_tagging_data_is_available_at_a_spreadsheet_url
    when_i_provide_the_public_uri_of_this_spreadsheet
    then_i_see_an_error_summary_instead_of_a_tagging_preview
    when_i_correct_the_data_and_reimport
    then_i_can_preview_which_taggings_will_be_imported
  end

  scenario "Deleting tagging spreadsheets" do
    given_tagging_data_is_present_in_a_google_spreadsheet
    when_i_provide_the_public_uri_of_this_spreadsheet
    and_i_delete_the_tagging_spreadsheet
    then_it_is_no_longer_available
    and_it_has_been_marked_as_deleted
  end

  SHEET_KEY = "THE-KEY-123".freeze
  SHEET_GID = "123456".freeze

  def when_i_correct_the_data_and_reimport
    given_tagging_data_is_present_in_a_google_spreadsheet
    click_link "Refresh import"
    click_link "Tag Importer"
  end

  def given_tagging_data_is_present_in_a_google_spreadsheet
    stub_request(:get, google_sheet_url(key: SHEET_KEY, gid: SHEET_GID))
      .to_return(body: google_sheet_fixture)
  end

  def then_i_see_an_error_summary_instead_of_a_tagging_preview
    click_link "Preview"
    expect(page).to have_content "An error occured"
  end

  def given_no_tagging_data_is_available_at_a_spreadsheet_url
    stub_request(:get, google_sheet_url(key: SHEET_KEY, gid: SHEET_GID))
      .to_return(status: 404)
  end

  def when_i_provide_the_public_uri_of_this_spreadsheet
    visit root_path
    click_link "Tag Importer"
    click_link "Upload spreadsheet"
    fill_in "Spreadsheet URL", with: google_sheet_url(key: SHEET_KEY, gid: SHEET_GID)
    click_button "Upload"
  end

  def then_i_can_preview_which_taggings_will_be_imported
    click_link "Preview"
    expect_page_to_contain_details_of(tag_mappings: TagMapping.all)
    expect_tag_mapping_statuses_to_be("No")
  end

  def expect_tag_mapping_statuses_to_be(string)
    tag_mapping_statuses = page.all(".tag-mapping-status")
    expect(tag_mapping_statuses.count).to eq TagMapping.count
    tag_mapping_statuses.each do |status|
      expect(status.text).to include string
    end
  end

  def expect_page_to_contain_details_of(tag_mappings: [])
    tag_mappings.each do |tag_mapping|
      expect(page).to have_content tag_mapping.content_base_path
      expect(page).to have_content tag_mapping.link_title
      expect(page).to have_content tag_mapping.link_type
    end
  end

  def and_confirming_this_will_import_taggings
    publishing_api_has_lookups(google_sheet_content_items)
    link_update_1 = stub_publishing_api_patch_links(
      "content-1-cid",
      links: {
        taxons: ["education-content-id", "education-content-id"],
        organisations: ["cabinet-office-content-id"],
      }
    )
    link_update_2 = stub_publishing_api_patch_links(
      "content-2-cid",
      links: {
        taxons: ["early-years-content-id"],
      }
    )

    click_link "Create tags"
    expect(link_update_1).to have_been_requested
    expect(link_update_2).to have_been_requested
    expect_tag_mapping_statuses_to_be("Yes")
  end

  def given_some_imported_tags
    given_tagging_data_is_present_in_a_google_spreadsheet
    when_i_provide_the_public_uri_of_this_spreadsheet
    then_i_can_preview_which_taggings_will_be_imported
  end

  def when_i_update_the_spreadsheet
    extra_row = google_sheet_row(
      content_base_path: "/content-2/",
      link_title: "GDS",
      link_content_id: "gds-content-id",
      link_type: "organisation",
    )
    stub_request(:get, google_sheet_url(key: SHEET_KEY, gid: SHEET_GID))
      .to_return(body: google_sheet_fixture([extra_row]))
  end

  def and_refetch_the_tags
    expect { click_link "Refresh import" }.to change { TagMapping.count }.by(1)
  end

  def then_i_should_see_an_updated_preview
    expect_page_to_contain_details_of(tag_mappings: TagMapping.all)
  end

  def and_i_delete_the_tagging_spreadsheet
    delete_button = first('table tbody a', text: 'Delete')

    expect { delete_button.click }.to_not change { TaggingSpreadsheet.count }
  end

  def then_it_is_no_longer_available
    rows = all('table tbody tr')
    expect(rows.count).to eq(0)
  end

  def and_it_has_been_marked_as_deleted
    tagging_spreadsheet = TaggingSpreadsheet.first
    expect(tagging_spreadsheet.deleted_at).to_not be_nil
  end
end
