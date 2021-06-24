require "rails_helper"

SHEET_KEY = "THE-KEY-123".freeze
SHEET_GID = "123456".freeze

RSpec.feature "Tag importer", type: :feature do
  include GoogleSheetHelper
  include PublishingApiHelper

  before do
    Sidekiq::Testing.inline!
    @name = GDS::SSO.test_user.name
  end

  scenario "Importing tags" do
    given_tagging_data_is_present_in_a_google_spreadsheet
    when_i_provide_the_public_uri_of_this_spreadsheet
    then_i_can_see_it_is_ready_for_importing
    then_i_can_preview_which_taggings_will_be_imported
    and_confirming_this_will_import_taggings
    and_i_visit_the_bulk_tag_by_upload_page
    then_the_state_of_the_import_is_successful
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
    then_i_see_the_import_failed
    then_i_see_an_error_summary_instead_of_a_tagging_preview
    when_i_correct_the_data_and_reimport
    then_i_can_preview_which_taggings_will_be_imported
  end

  scenario "The spreadsheet contains a draft content item" do
    given_tagging_data_is_present_in_a_google_spreadsheet
    when_i_provide_the_public_uri_of_this_spreadsheet
    then_i_can_see_it_is_ready_for_importing
    then_i_can_preview_which_taggings_will_be_imported
    and_confirming_only_valid_tags_will_be_imported
    and_i_visit_the_bulk_tag_by_upload_page
    then_the_state_of_the_import_is_unsuccessful
  end

  scenario "Deleting tagging spreadsheets" do
    given_tagging_data_is_present_in_a_google_spreadsheet
    when_i_provide_the_public_uri_of_this_spreadsheet
    and_i_delete_the_tagging_spreadsheet
    then_it_is_no_longer_available
    and_it_has_been_marked_as_deleted
  end

  scenario "Ordering of tag mappings" do
    given_tagging_data_is_present_in_a_google_spreadsheet
    when_i_provide_the_public_uri_of_this_spreadsheet
    then_i_can_see_it_is_ready_for_importing
    then_i_can_preview_which_taggings_will_be_imported
    and_confirming_this_will_import_taggings
    when_the_last_tag_mapping_has_errored
    when_i_preview_the_tagging_spreadsheet
    then_the_erroneous_tag_mappings_are_at_the_top
  end

  scenario "Consolidate tag mappings" do
    given_tagging_spreadsheet_exists
    when_i_go_to_the_tagging_spreadsheet_page
    then_i_expect_tag_mappings_to_be_grouped_by_base_path
  end

  def when_i_correct_the_data_and_reimport
    given_tagging_data_is_present_in_a_google_spreadsheet
    click_link I18n.t("tag_import.refresh")
  end

  def given_tagging_data_is_present_in_a_google_spreadsheet
    stub_request(:get, google_sheet_url(key: SHEET_KEY, gid: SHEET_GID))
      .to_return(status: 200, body: google_sheet_fixture)
  end

  def then_i_see_an_error_summary_instead_of_a_tagging_preview
    expect(page).to have_content "An error occured"
  end

  def given_no_tagging_data_is_available_at_a_spreadsheet_url
    stub_request(:get, google_sheet_url(key: SHEET_KEY, gid: SHEET_GID))
      .to_return(status: 404, body: "uh-oh")
  end

  def when_i_provide_the_public_uri_of_this_spreadsheet
    publishing_api_has_taxons([])

    visit root_path
    click_link I18n.t("navigation.bulk_tag")

    click_link I18n.t("navigation.tag_importer")
    click_link I18n.t("tag_import.upload_sheet")
    expect(page).to have_text(/how to generate a google spreadsheet url/i)
    fill_in I18n.t("tag_import.sheet_url"), with: google_sheet_url(key: SHEET_KEY, gid: SHEET_GID)
    click_button I18n.t("tag_import.upload")
    expect(BulkTagging::TaggingSpreadsheet.count).to eq 1
    expect(BulkTagging::TaggingSpreadsheet.first.added_by.name).to eq @name
  end

  def given_tagging_spreadsheet_exists
    tagging_spreadsheet = build(:tagging_spreadsheet)
    tagging_spreadsheet.tag_mappings << build(:tag_mapping, link_content_id: "a-content-id-1", link_title: "Education")
    tagging_spreadsheet.tag_mappings << build(:tag_mapping, link_content_id: "a-content-id-2", link_title: "Early Years")

    tagging_spreadsheet.save!
  end

  def when_i_go_to_the_tagging_spreadsheet_page
    visit tagging_spreadsheet_path(BulkTagging::TaggingSpreadsheet.last)
  end

  def then_i_expect_tag_mappings_to_be_grouped_by_base_path
    rows = all("table tbody tr")
    expect(rows.count).to eq(1)

    first_row = rows.first

    BulkTagging::TagMapping.all.each do |tag_mapping|
      expect(page).to have_content(tag_mapping.content_base_path, count: 1)
      expect(first_row.text).to include(tag_mapping.link_title)
    end
  end

  def then_i_can_preview_which_taggings_will_be_imported
    expect_page_to_contain_details_of(tag_mappings: BulkTagging::TagMapping.all)
    expect(page).to have_text(
      I18n.t("views.tag_update_progress_bar", completed: 0, total: 2),
    )
    expect_tag_mapping_statuses_to_be("Ready to tag")
  end

  def expect_tag_mapping_statuses_to_be(string)
    tag_mapping_statuses = page.all(".tag-mapping-status")
    expect(tag_mapping_statuses.count).to eq BulkTagging::TaggingSpreadsheet.first.aggregated_tag_mappings.count

    tag_mapping_statuses.each do |status|
      expect(status.text).to include string
    end
  end

  def expect_different_tag_mapping_statuses_to_be(*statuses)
    tag_mapping_statuses = page.all(".tag-mapping-status")

    expect(tag_mapping_statuses.count).to eq BulkTagging::TaggingSpreadsheet.first.aggregated_tag_mappings.count

    tag_mapping_statuses.zip(statuses).each do |status, expected_status|
      expect(status.text).to include expected_status
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
    stub_publishing_api_has_lookups(google_sheet_content_items)
    stub_publishing_api_has_links(content_id: "content-2-cid", links: { taxons: [] })
    stub_publishing_api_has_links(content_id: "content-1-cid", links: { taxons: [] })
    link_update1 = stub_publishing_api_patch_links(
      "content-1-cid",
      links: {
        taxons: %w[education-content-id],
      },
      bulk_publishing: true,
    )
    link_update2 = stub_publishing_api_patch_links(
      "content-2-cid",
      links: {
        taxons: %w[early-years-content-id],
      },
      bulk_publishing: true,
    )
    taxon1 = { title: "Early Years", content_id: "early-years-content-id" }
    taxon2 = { title: "Education", content_id: "education-content-id" }
    publishing_api_has_taxons([taxon1, taxon2])

    click_link I18n.t("tag_import.start_tagging")
    expect(link_update1).to have_been_requested
    expect(link_update2).to have_been_requested
    expect_tag_mapping_statuses_to_be("Tagged")
  end

  def and_confirming_only_valid_tags_will_be_imported
    stub_publishing_api_has_lookups(google_sheet_content_items_with_draft)
    stub_publishing_api_has_links(content_id: "content-2-cid", links: { taxons: [] })
    stub_publishing_api_has_links(content_id: "content-1-cid", links: { taxons: [] })
    link_update1 = stub_publishing_api_patch_links(
      "content-1-cid",
      links: {
        taxons: %w[education-content-id],
      },
      bulk_publishing: true,
    )

    taxon1 = { title: "Early Years", content_id: "early-years-content-id" }
    taxon2 = { title: "Education", content_id: "education-content-id" }
    publishing_api_has_taxons([taxon1, taxon2])

    click_link I18n.t("tag_import.start_tagging")
    expect(link_update1).to have_been_requested
    expect_different_tag_mapping_statuses_to_be("Error", "Tagged")
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
      link_type: "taxons",
    )
    stub_request(:get, google_sheet_url(key: SHEET_KEY, gid: SHEET_GID))
      .to_return(status: 200, body: google_sheet_fixture([extra_row]))
  end

  def and_refetch_the_tags
    expect { click_link I18n.t("tag_import.refresh") }.to(change { BulkTagging::TagMapping.count }.by(1))
  end

  def then_i_should_see_an_updated_preview
    expect_page_to_contain_details_of(tag_mappings: BulkTagging::TagMapping.all)
  end

  def and_i_delete_the_tagging_spreadsheet
    visit tagging_spreadsheets_path
    delete_button = first("table tbody a", text: I18n.t("tag_import.delete"))

    expect { delete_button.click }.to_not(change { BulkTagging::TaggingSpreadsheet.count })
  end

  def then_it_is_no_longer_available
    rows = all("table tbody tr")
    expect(rows.count).to eq(0)
  end

  def and_it_has_been_marked_as_deleted
    tagging_spreadsheet = BulkTagging::TaggingSpreadsheet.first
    expect(tagging_spreadsheet.deleted_at).to_not be_nil
  end

  def then_i_can_see_it_is_ready_for_importing
    visit tagging_spreadsheets_path
    tagging_spreadsheet = BulkTagging::TaggingSpreadsheet.first
    state = tagging_spreadsheet.state
    state_message = I18n.t("bulk_tagging.state.#{state}")

    row = first("table tbody tr")

    expect(row).to have_selector(".label-warning", text: state_message)
    visit tagging_spreadsheet_path(tagging_spreadsheet)
  end

  def then_i_see_the_import_failed
    visit tagging_spreadsheets_path
    tagging_spreadsheet = BulkTagging::TaggingSpreadsheet.first
    state = tagging_spreadsheet.state.humanize
    row = first("table tbody tr")

    expect(row).to have_selector(".label-danger", text: state)
    visit tagging_spreadsheet_path(tagging_spreadsheet)
  end

  def then_the_state_of_the_import_is_successful
    tagging_spreadsheet = BulkTagging::TaggingSpreadsheet.first
    expect_spreadsheet_label(tagging_spreadsheet, ".label-success")
  end

  def then_the_state_of_the_import_is_unsuccessful
    tagging_spreadsheet = BulkTagging::TaggingSpreadsheet.first
    expect_spreadsheet_label(tagging_spreadsheet, ".label-danger")
  end

  def expect_spreadsheet_label(tagging_spreadsheet, label_class)
    state = tagging_spreadsheet.state
    state_message = I18n.t("bulk_tagging.state.#{state}")
    row = first("table tbody tr")

    expect(row).to have_selector(label_class, text: state_message)
  end

  def and_i_visit_the_bulk_tag_by_upload_page
    visit root_path
    click_link I18n.t("navigation.bulk_tag")

    click_link I18n.t("navigation.tag_importer")
  end

  def when_the_last_tag_mapping_has_errored
    tag_mapping = BulkTagging::TagMapping.last
    tag_mapping.state = "errored"
    tag_mapping.messages = ["An error message"]
    tag_mapping.save!
  end

  def when_i_preview_the_tagging_spreadsheet
    visit tagging_spreadsheets_path
    tagging_spreadsheet = BulkTagging::TaggingSpreadsheet.first
    visit tagging_spreadsheet_path(tagging_spreadsheet)
  end

  def then_the_erroneous_tag_mappings_are_at_the_top
    tag_mapping = BulkTagging::TagMapping.where(state: "errored").first
    first_row = find("table tbody").first("tr")

    expect(first_row.text).to match(tag_mapping.content_base_path)
    expect(first_row.text).to match(tag_mapping.link_title)
    expect(first_row.text).to match(/errored/i)
  end
end
