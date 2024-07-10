RSpec.feature "Bulk tagging" do
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

  scenario "Creating tags shows progress", :js do
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

    publishing_api_has_content_items(
      [document_collection],
      q: "Tax",
    )

    stub_publishing_api_has_item(document_collection)

    publishing_api_has_content_items(
      [{
        content_id: "browse-page-id",
        title: "A Mainstream Browse Page",
        base_path: "/a-maintstream-browse-page",
        document_type: "mainstream_browse_page",
      }],
      q: "browse",
    )

    stub_publishing_api_has_expanded_links({
      content_id: "collection-id",
      expanded_links: {
        documents: [
          basic_content_item("Tax doc 1"),
          basic_content_item("Tax doc 2"),
        ],
      },
    })
  end

  def and_a_set_of_taxons
    stub_publishing_api_has_item(basic_content_item("Taxon 1"))
    stub_publishing_api_has_item(basic_content_item("Taxon 2"))

    # Used in the dropdown
    stub_publishing_api_has_linkables(
      [
        build_linkable(internal_name: "Taxon 1", content_id: "taxon-1"),
        build_linkable(internal_name: "Taxon 2", content_id: "taxon-2"),
        build_linkable(internal_name: "Taxon 3", content_id: "taxon-3"),
      ],
      document_type: "taxon",
    )
  end

  def when_i_search_for_the_collection
    visit new_bulk_tag_path

    fill_in "bulk_tag_query", with: "browse"
    click_button I18n.t("bulk_tag.search_button")
    expect(page).to have_text("A Mainstream Browse Page")

    fill_in "bulk_tag_query", with: "Tax"
    click_button I18n.t("bulk_tag.search_button")
    expect(page).to have_text("Tax documents")
    expect(page).to have_text("Document collection")
    expect(page).to have_link(
      "View tagged pages",
      href: new_tag_migration_path(source_content_id: "collection-id"),
    )
  end

  def then_i_can_see_the_content_items_in_this_collection
    within "main" do
      click_link I18n.t("bulk_tag.view_tagged_pages")
    end

    within "form.new_bulk_tagging_tag_migration" do
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

    expect(all("table tbody tr").count).to eq BulkTagging::TagMigration.first.aggregated_tag_mappings.count
    expect(page).to have_text("Taxon 1", count: 2)
    expect(page).to have_text("Taxon 2", count: 2)
    expect(page).to have_text("/level-one/tax-doc-1", count: 1)
    expect(page).to have_text("/level-one/tax-doc-2", count: 1)
    expect(page).to have_text(
      I18n.t("views.tag_update_progress_bar", completed: 0, total: 2),
    )

    within("table") do
      state_labels = all("span.label")
      state_labels.each { |label| expect(label.text).to match(/Ready to tag/) }
    end
  end

  def when_i_create_tags
    stub_publishing_api_has_links(content_id: "tax-doc-1", links: { taxons: [] })
    stub_publishing_api_has_links(content_id: "tax-doc-2", links: { taxons: [] })
    stub_publishing_api_has_lookups(
      "/level-one/tax-doc-1" => "tax-doc-1",
      "/level-one/tax-doc-2" => "tax-doc-2",
    )
    stub_publishing_api_patch_links(
      "tax-doc-1",
      links: { taxons: %w[taxon-1] },
      bulk_publishing: true,
    )
    stub_publishing_api_patch_links(
      "tax-doc-1",
      links: { taxons: %w[taxon-2] },
      bulk_publishing: true,
    )
    stub_publishing_api_patch_links(
      "tax-doc-2",
      links: { taxons: %w[taxon-1] },
      bulk_publishing: true,
    )
    stub_publishing_api_patch_links(
      "tax-doc-2",
      links: { taxons: %w[taxon-2] },
      bulk_publishing: true,
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
    expect(page).to have_text "No taxons selected."
  end

  def when_i_submit_the_form
    click_button I18n.t("bulk_tagging.preview")
  end

  def then_i_see_an_error_about_content_items
    expect(page).to have_text "No content items selected."
  end

  def when_i_select_taxons
    select "Taxon 1", from: "taxons"
  end

  def when_i_go_to_all_migrations
    visit tag_migrations_path
  end

  def then_i_can_see_it_has_been_imported
    expect(all("table tbody tr").count).to eq(1)

    row = first("table tbody tr")

    expect(row).to have_text(/Tagging completed/i)
    expect(row).to have_text("Tax documents (Document collection)")
  end

  def given_a_tag_migration_exists
    tag_migration = build(:tag_migration)
    tag_mapping = build(:tag_mapping)
    tag_migration.tag_mappings << tag_mapping
    tag_migration.save!

    stub_publishing_api_has_item(
      content_id: tag_migration.source_content_id,
      title: "Source content",
      document_type: "taxon",
      base_path: "/source-content",
    )

    stub_publishing_api_has_lookups(tag_mapping.content_base_path => "content-id")
    publishing_api_has_taxons(
      [
        basic_content_item(
          tag_mapping.link_title,
          other_fields: {
            content_id: tag_mapping.link_content_id,
            document_type: tag_mapping.link_type,
          },
        ),
      ],
    )
    stub_publishing_api_has_links(
      content_id: "content-id",
      links: { taxons: [] },
      version: 0,
    )
    stub_publishing_api_patch_links(
      "content-id",
      links: {
        taxons: [tag_mapping.link_content_id],
      },
      bulk_publishing: true,
      previous_version: 0,
    )
  end

  def when_i_go_to_the_tag_migration_page_and_create_tags
    tag_migration = BulkTagging::TagMigration.last

    visit tag_migration_path(tag_migration.id)

    Sidekiq::Testing.inline!
    click_link I18n.t("bulk_tagging.start_tagging")
  end

  def then_i_can_see_a_progress_bar
    expect(page).to have_selector(".progress-bar")

    bar = find(".progress-bar")
    max_value = bar["aria-valuemax"]
    current_value = bar["aria-valuenow"]

    expect(current_value).to eq(max_value)
  end
end
