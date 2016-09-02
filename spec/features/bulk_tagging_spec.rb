require "rails_helper"

RSpec.feature "Bulk tagging", type: :feature do
  require 'gds_api/test_helpers/publishing_api_v2'
  include GdsApi::TestHelpers::PublishingApiV2
  include ContentItemHelper

  scenario "Migrating tags from a collection to taxons" do
    given_a_collection_with_items
    and_a_set_of_taxons
    when_i_find_the_collection_via_the_bulk_tagger
    then_i_can_see_the_content_items_in_this_collection
    when_i_select_the_taxons_i_want_to_retag_them_to
    then_i_can_preview_my_changes
    when_i_create_tags
    then_the_content_items_have_been_retagged
  end

  scenario "Not selecting anything to migrate" do
    given_a_collection_with_items
    and_a_set_of_taxons
    when_i_find_the_collection_via_the_bulk_tagger
    then_i_can_see_the_content_items_in_this_collection
    when_i_submit_the_form
    then_i_see_an_error_about_taxons
    when_i_select_taxons
    when_i_deselect_all_content_items
    when_i_submit_the_form
    then_i_see_an_error_about_content_items
  end

  def given_a_collection_with_items
    publishing_api_has_content(
      [{
        content_id: "collection-id",
        title: "Tax documents",
        base_path: "/tax-documents",
        document_type: "document_collection",
      }],
      document_type: "document_collection",
      per_page: 20,
      q: "Tax"
    )

    publishing_api_has_expanded_links(
      content_id: "collection-id",
      expanded_links: {
        documents: [
          basic_content_item("Tax doc 1"),
          basic_content_item("Tax doc 2"),
        ]
      }
    )
  end

  def and_a_set_of_taxons
    linkables = [
      basic_content_item("Taxon 1"),
      basic_content_item("Taxon 2"),
      basic_content_item("Taxon 3"),
    ]
    publishing_api_has_linkables(linkables, document_type: 'taxon')
  end

  def when_i_find_the_collection_via_the_bulk_tagger
    visit new_bulk_tagging_path
    fill_in "Query", with: "Tax"
    click_button "Search collection"
    expect(page).to have_text("Tax documents")
    expect(page).to have_link("collection-id")
  end

  def then_i_can_see_the_content_items_in_this_collection
    click_link("collection-id")
    expect(page).to have_text "Tax doc 1"
    expect(page).to have_text "Tax doc 2"
    expect(page).to have_link "tax-doc-1"
    expect(page).to have_link "tax-doc-2"
    # All content items checked by default
    expect(all("input[type='checkbox']").select(&:checked?).count).to eq 2
  end

  def when_i_select_the_taxons_i_want_to_retag_them_to
    select "Taxon 1", from: "taxons"
    select "Taxon 2", from: "taxons"
  end

  def then_i_can_preview_my_changes
    click_button "Bulk tag selected items"

    expect(all("table tbody tr").count).to eq 4
    expect(page).to have_text("Taxon 1", count: 2)
    expect(page).to have_text("Taxon 2", count: 2)
    expect(page).to have_text("/path/tax-doc-1", count: 2)
    expect(page).to have_text("/path/tax-doc-2", count: 2)

    within("table") do
      state_labels = all("span.label")
      state_labels.each { |label| expect(label.text).to match(/Ready to tag/) }
    end
  end

  def when_i_create_tags
    publishing_api_has_lookups(
      '/path/tax-doc-1' => 'tax-doc-1',
      '/path/tax-doc-2' => 'tax-doc-2',
    )
    stub_publishing_api_patch_links(
      "tax-doc-1",
      links: {
        taxons: ["taxon-1", "taxon-2"],
      }
    )
    stub_publishing_api_patch_links(
      "tax-doc-2",
      links: {
        taxons: ["taxon-1", "taxon-2"],
      }
    )

    Sidekiq::Testing.inline!
    click_link 'Create tags'
  end

  def then_the_content_items_have_been_retagged
    # Refresh the page so we see the updates
    visit current_path

    within("table") do
      state_labels = all("span.label")
      state_labels.each { |label| expect(label.text).to match(/tagged/i) }
    end
  end

  def when_i_deselect_all_content_items
    all("input[type='checkbox']").each do |checkbox|
      checkbox.set false
    end
  end

  def then_i_see_an_error_about_taxons
    expect(page).to have_text 'No taxons selected.'
  end

  def when_i_submit_the_form
    click_button "Bulk tag selected items"
  end

  def then_i_see_an_error_about_content_items
    expect(page).to have_text 'No content items selected.'
  end

  def when_i_select_taxons
    select "Taxon 1", from: "taxons"
  end
end
