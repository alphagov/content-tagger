require "rails_helper"

RSpec.feature "Bulk tagging", type: :feature do
  require 'gds_api/test_helpers/publishing_api_v2'
  include GdsApi::TestHelpers::PublishingApiV2
  include ContentItemHelper
  include PublishingApiHelper

  scenario "Migrating tags from a collection to taxons" do
    given_a_collection_with_items_and_some_other_content_groupings
    and_a_set_of_taxons
    when_i_search_for_the_collection
    then_i_can_see_the_content_items_in_this_collection
    when_i_select_the_taxons_i_want_to_tag_them_to
    then_i_can_preview_my_changes
    when_i_create_tags
    then_the_content_items_have_been_tagged
    when_i_go_to_all_migrations
    then_i_can_see_it_has_been_imported
  end

  scenario "Not selecting anything to migrate" do
    given_a_collection_with_items_and_some_other_content_groupings
    and_a_set_of_taxons
    when_i_search_for_the_collection
    then_i_can_see_the_content_items_in_this_collection
    when_i_submit_the_form
    then_i_see_an_error_about_taxons
    when_i_select_taxons
    when_i_deselect_all_content_items
    when_i_submit_the_form
    then_i_see_an_error_about_content_items
  end

  scenario "Creating tags shows progress", js: true do
    given_a_tag_migration_exists
    when_i_go_to_the_tag_migration_page_and_create_tags
    then_i_can_see_a_progress_bar
  end

  def given_a_collection_with_items_and_some_other_content_groupings
    document_collection = {
      content_id: "collection-id",
      title: "Tax documents",
      base_path: "/tax-documents",
      document_type: "document_collection",
    }

    publishing_api_has_content(
      [document_collection],
      document_type: BulkTagging::Search.default_document_types,
      page: 1,
      q: "Tax"
    )

    publishing_api_has_item(document_collection)

    publishing_api_has_content(
      [{
        content_id: "topic-id",
        title: "A Topic",
        base_path: "/a-topic",
        document_type: "topic",
      }],
      document_type: BulkTagging::Search.default_document_types,
      page: 1,
      q: "topic"
    )

    publishing_api_has_content(
      [{
        content_id: "browse-page-id",
        title: "A Mainstream Browse Page",
        base_path: "/a-maintstream-browse-page",
        document_type: "mainstream_browse_page",
      }],
      document_type: BulkTagging::Search.default_document_types,
      page: 1,
      q: "browse"
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
    publishing_api_has_item(basic_content_item("Taxon 1"))
    publishing_api_has_item(basic_content_item("Taxon 2"))

    # Used in the dropdown
    publishing_api_has_linkables(
      [
        build_linkable(internal_name: "Taxon 1", content_id: 'taxon-1'),
        build_linkable(internal_name: "Taxon 2", content_id: 'taxon-2'),
        build_linkable(internal_name: "Taxon 3", content_id: 'taxon-3'),
      ],
      document_type: "taxon",
    )
  end

  def when_i_search_for_the_collection
    visit new_tag_search_path

    fill_in "Query", with: "topic"
    click_button I18n.t('tag_search.search_button')
    expect(page).to have_text("A Topic")

    fill_in "Query", with: "browse"
    click_button I18n.t('tag_search.search_button')
    expect(page).to have_text("A Mainstream Browse Page")

    fill_in "Query", with: "Tax"
    click_button I18n.t('tag_search.search_button')
    expect(page).to have_text("Tax documents")
    expect(page).to have_text('Document collection')
    expect(page).to have_link(
      "Bulk tag",
      href: new_tag_migration_path(source_content_id: "collection-id")
    )
  end

  def then_i_can_see_the_content_items_in_this_collection
    within "main" do
      click_link I18n.t("tag_search.bulk_tag")
    end

    within "form.new_tag_migration" do
      expect(page).to have_text "Tax doc 1"
      expect(page).to have_link "View on site", href: /tax-doc-1/
      expect(page).to have_text "Tax doc 2"
      expect(page).to have_link "View on site", href: /tax-doc-2/
    end

    expect(all(".select-content-item").select(&:checked?).count).to eq 0
    when_i_select_all_content_items
    expect(all(".select-content-item").select(&:checked?).count).to eq 2
  end

  def when_i_select_the_taxons_i_want_to_tag_them_to
    select "Taxon 1", from: "taxons"
    select "Taxon 2", from: "taxons"
  end

  def then_i_can_preview_my_changes
    click_button I18n.t("bulk_tagging.preview")

    expect(all("table tbody tr").count).to eq TagMigration.first.aggregated_tag_mappings.count
    expect(page).to have_text("Taxon 1", count: 2)
    expect(page).to have_text("Taxon 2", count: 2)
    expect(page).to have_text("/path/tax-doc-1", count: 1)
    expect(page).to have_text("/path/tax-doc-2", count: 1)
    expect(page).to have_text("0 of 2 content items updated")

    within("table") do
      state_labels = all("span.label")
      state_labels.each { |label| expect(label.text).to match(/Ready to tag/) }
    end
  end

  def when_i_create_tags
    publishing_api_has_links(content_id: "tax-doc-1", links: { taxons: [] })
    publishing_api_has_links(content_id: "tax-doc-2", links: { taxons: [] })
    publishing_api_has_lookups(
      '/path/tax-doc-1' => 'tax-doc-1',
      '/path/tax-doc-2' => 'tax-doc-2',
    )
    stub_publishing_api_patch_links(
      "tax-doc-1",
      links: { taxons: ["taxon-1"] }
    )
    stub_publishing_api_patch_links(
      "tax-doc-1",
      links: { taxons: ["taxon-2"] }
    )
    stub_publishing_api_patch_links(
      "tax-doc-2",
      links: { taxons: ["taxon-1"] }
    )
    stub_publishing_api_patch_links(
      "tax-doc-2",
      links: { taxons: ["taxon-2"] }
    )

    Sidekiq::Testing.inline!
    click_link I18n.t("bulk_tagging.start_tagging")
  end

  def then_the_content_items_have_been_tagged
    # Refresh the page so we see the updates
    visit current_path

    within("table") do
      state_labels = all("span.label")
      state_labels.each { |label| expect(label.text).to match(/tagged/i) }
    end
  end

  def when_i_deselect_all_content_items
    all(".select-content-item").each do |checkbox|
      checkbox.set false
    end
  end

  def when_i_select_all_content_items
    all(".select-content-item").each do |checkbox|
      checkbox.set true
    end
  end

  def then_i_see_an_error_about_taxons
    expect(page).to have_text 'No taxons selected.'
  end

  def when_i_submit_the_form
    click_button I18n.t("bulk_tagging.preview")
  end

  def then_i_see_an_error_about_content_items
    expect(page).to have_text 'No content items selected.'
  end

  def when_i_select_taxons
    select "Taxon 1", from: "taxons"
  end

  def when_i_go_to_all_migrations
    visit tag_migrations_path
  end

  def then_i_can_see_it_has_been_imported
    expect(all('table tbody tr').count).to eq(1)

    row = first('table tbody tr')

    expect(row).to have_text(/imported/i)
    expect(row).to have_text('Tax documents (Document collection)')
  end

  def given_a_tag_migration_exists
    tag_migration = build(:tag_migration)
    tag_mapping = build(:tag_mapping)
    tag_migration.tag_mappings << tag_mapping
    tag_migration.save!

    publishing_api_has_lookups(tag_mapping.content_base_path => 'content-id')
    publishing_api_has_taxons(
      [
        basic_content_item(
          tag_mapping.link_title,
          other_fields: {
            content_id: tag_mapping.link_content_id,
            document_type: tag_mapping.link_type
          }
        )
      ]
    )
    publishing_api_has_links(
      content_id: 'content-id',
      links: { taxons: [] },
      version: 0
    )
    stub_publishing_api_patch_links(
      'content-id',
      links: {
        taxons: [tag_mapping.link_content_id]
      },
      previous_version: 0
    )
  end

  def when_i_go_to_the_tag_migration_page_and_create_tags
    tag_migration = TagMigration.last

    visit tag_migration_path(tag_migration.id)

    Sidekiq::Testing.inline!
    click_link I18n.t("bulk_tagging.start_tagging")
  end

  def then_i_can_see_a_progress_bar
    expect(page).to have_selector('.progress-bar')

    bar = find('.progress-bar')
    max_value = bar['aria-valuemax']
    current_value = bar['aria-valuenow']

    expect(current_value).to eq(max_value)
  end
end
