require "rails_helper"

RSpec.feature "Taxonomy editing" do
  include EmailAlertApiHelper
  include PublishingApiHelper
  include ContentItemHelper

  before do
    @taxon1 = taxon_with_details(
      "School planning",
      other_fields: {
        content_id: "ID-1",
        base_path: "/education/1",
        publication_state: "published",
        state_history: {
          "1" => "published",
        },
      },
    )
    @taxon2 = taxon_with_details(
      "Starting and attending school (draft)",
      other_fields: {
        content_id: "ID-2",
        base_path: "/education/2",
        publication_state: "draft",
        state_history: {
          "1" => "draft",
        },
      },
    )
    @taxon3 = taxon_with_details(
      "Rail",
      other_fields: {
        content_id: "ID-3",
        base_path: "/transport/rail",
        publication_state: "published",
        state_history: {
          "1" => "published",
        },
      },
    )
    @linkable_taxon1 = {
      title: "School planning",
      content_id: "ID-1",
      base_path: "/education/1",
      internal_name: "School planning",
      publication_state: "published",
      state_history: {
        "1" => "published",
      },
    }
    @linkable_taxon2 = {
      title: "Starting and attending school (draft)",
      content_id: "ID-2",
      base_path: "/education/2",
      internal_name: "Starting and attending school (draft)",
      publication_state: "draft",
      state_history: {
        "1" => "draft",
      },
    }
    @linkable_taxon3 = {
      title: "Rail",
      content_id: "ID-3",
      base_path: "/transport/rail",
      internal_name: "Rail",
      publication_state: "published",
      state_history: {
        "1" => "published",
      },
    }

    @dummy_editor_notes = "Some usage notes for this taxon."

    @create_item = stub_request(:put, %r{https://publishing-api.test.gov.uk/v2/content*})
      .with(
        body: hash_including(
          base_path: "/education/newly-created-taxon",
        ),
      )
      .to_return(status: 200, body: {}.to_json)

    @create_links = stub_request(:patch, %r{https://publishing-api.test.gov.uk/v2/links*})
      .to_return(status: 200, body: {}.to_json)

    @create_links_with_associated_taxons = stub_request(:patch, %r{https://publishing-api.test.gov.uk/v2/links*})
      .with(
        body: {
          links: {
            root_taxon: [],
            parent_taxons: %w[ID-1],
            associated_taxons: array_including("ID-2", "ID-3"),
            legacy_taxons: [],
          },
        },
      )
      .to_return(status: 200, body: {}.to_json)
  end

  scenario "User creates a taxon with a parent" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_new_taxon_button
    and_i_set_taxon_details
    and_i_submit_the_create_form
    then_a_taxon_is_created
  end

  scenario "User creates a child taxon from a parent" do
    given_there_are_taxons
    when_i_visit_the_taxon_page
    and_i_click_on_the_add_a_child_taxon_button
    then_the_parent_is_correctly_prefilled
  end

  scenario "User creates a taxon with associated taxons" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_new_taxon_button
    and_i_set_taxon_details
    and_i_select_associated_taxons
    and_i_submit_the_create_form
    then_a_taxon_with_associated_taxons_is_created
  end

  scenario "User creates a taxon without a parent" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_new_taxon_button
    and_i_set_taxon_details
    and_i_submit_the_create_form
    then_a_taxon_is_created
  end

  scenario "User attempts to create a taxon that isn't semantically valid" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_new_taxon_button
    and_i_submit_the_taxon_with_a_taxon_with_semantic_issues_from_the_publishing_api
    then_i_can_see_a_generic_error_message
  end

  scenario "User attempts to create a taxon with a duplicate base path" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_new_taxon_button
    and_i_submit_the_taxon_with_a_taxon_with_a_duplicate_base_path
    then_i_can_see_a_specific_error_message
  end

  scenario "User edits a live taxon" do
    given_there_are_taxons
    when_i_visit_the_taxon_page
    and_i_click_on_the_edit_taxon_button
    when_i_update_the_taxon
    then_my_taxon_is_updated
    and_my_taxon_is_not_published
  end

  scenario "User edits a draft taxon" do
    given_there_are_taxons
    when_i_visit_the_draft_taxon_page
    and_i_click_on_the_edit_taxon_button
    when_i_update_the_taxon
    then_my_taxon_is_updated
    and_my_taxon_is_not_published
  end

  scenario "Taxon base path preview when changing parent taxon", js: true do
    given_there_are_taxons
    when_i_visit_the_taxon_page
    and_i_click_on_the_edit_taxon_button
    when_i_change_the_parent_taxon_to_a_transport_branch
    then_the_base_path_prefix_hint_is_updated
  end

  scenario "Path prefix is validated to match the parent path prefix" do
    given_there_are_taxons
    when_i_visit_the_taxon_page
    and_i_click_on_the_edit_taxon_button
    when_i_change_the_parent_taxon_to_a_transport_branch
    and_i_change_the_base_path_and_submit_the_form
    then_the_base_path_shows_as_invalid
  end

  scenario "User links to a legacy taxon" do
    given_there_are_taxons
    when_i_visit_the_taxon_page
    and_i_click_on_the_edit_taxon_button
    when_i_add_an_additional_legacy_taxon
    then_the_legacy_taxons_should_be_saved
  end

  def given_there_are_taxons
    publishing_api_has_linkables(
      [@linkable_taxon1, @linkable_taxon2, @linkable_taxon3],
      document_type: "taxon",
    )
    publishing_api_has_taxons([@taxon1, @taxon2, @taxon3])

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/ID-2")
      .to_return(body: { expanded_links: { parent_taxons: [] } }.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/ID-3")
      .to_return(body: { expanded_links: { parent_taxons: [] } }.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-1")
      .to_return(body: @taxon1.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-2")
      .to_return(body: @taxon2.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-3")
      .to_return(body: @taxon3.to_json)
  end

  def when_i_visit_the_taxon_page
    stub_publishing_api_has_expanded_links(
      content_id: @taxon1[:content_id],
      expanded_links: {
        parent_taxons: [
          {
            content_id: @taxon2[:content_id],
            base_path: @taxon2[:base_path],
            title: @taxon2[:title],
          },
        ],
        legacy_taxons: [
          {
            content_id: "CONTENT-ID-LEGACY-TAXON",
            base_path: "/legacy-taxon",
          },
        ],
      },
    )

    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/linked/*})
      .to_return(status: 200, body: {}.to_json)
    stub_email_requests_for_show_page

    visit taxon_path("ID-1")
  end

  def when_i_visit_the_draft_taxon_page
    stub_publishing_api_has_expanded_links(
      content_id: @taxon2[:content_id],
      expanded_links: {},
    )

    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/linked/*})
      .to_return(status: 200, body: {}.to_json)
    stub_email_requests_for_show_page

    visit taxon_path("ID-2")
  end

  def when_i_visit_the_taxonomy_page
    stub_email_requests_for_show_page

    visit taxons_path
  end

  def and_i_click_on_the_new_taxon_button
    click_on I18n.t("views.taxons.add_taxon")
  end

  def and_i_click_on_the_edit_taxon_button
    stub_email_requests_for_show_page

    click_on I18n.t("views.taxons.edit")
  end

  def and_i_click_on_the_add_a_child_taxon_button
    click_on I18n.t("views.taxons.add_child")
  end

  def and_i_set_taxon_details
    select "School planning", from: "Parent"
    fill_in :taxon_title, with: "Newly created taxon"
    fill_in :taxon_description, with: "A description of my lovely taxon."
    fill_in :taxon_internal_name, with: "Newly created taxon"
    fill_in :taxon_notes_for_editors, with: @dummy_editor_notes
    fill_in :taxon_base_path, with: "/education/newly-created-taxon"
  end

  def and_i_select_associated_taxons
    select @taxon2[:title], from: "taxon_associated_taxons"
    select @taxon3[:title], from: "taxon_associated_taxons"
  end

  def when_i_change_the_parent_taxon_to_a_transport_branch
    select "Rail", from: "Parent"
    return if Capybara.current_driver != :poltergeist

    wait_for_ajax
  end

  def and_i_change_the_base_path_and_submit_the_form
    fill_in "Base path", with: "/education/trains"
    find(".submit-button").click
  end

  def when_i_update_the_taxon
    fill_in :taxon_internal_name, with: "My updated taxon"
    fill_in :taxon_description, with: "Description of my updated taxon."
    fill_in :taxon_notes_for_editors, with: @dummy_editor_notes

    @update_item = stub_request(:put, %r{https://publishing-api.test.gov.uk/v2/content})
      .with(body: /details.*#{@dummy_editor_notes}/)
      .to_return(status: 200, body: {}.to_json)

    @publish_item = stub_request(:post, %r{https://publishing-api.test.gov.uk/v2/content/.*/publish})
      .to_return(status: 200, body: "", headers: {})

    stub_publishing_api_has_lookups("/legacy-taxon" => "CONTENT-ID-LEGACY-TAXON")

    stub_publishing_api_has_expanded_links(
      content_id: @taxon1[:content_id],
      expanded_links: {},
    )

    stub_publishing_api_has_expanded_links(
      content_id: @taxon2[:content_id],
      expanded_links: {},
    )

    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/linked/*})
      .to_return(status: 200, body: {}.to_json)

    find(".submit-button").click
  end

  def and_i_submit_the_create_form
    # Before the taxon is created, we compare the old attributes with the new,
    # to create a diff. In this instance, a previous version does not exist.
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(status: 404)
    # After the taxon is created we'll be redirected to the taxon's "view" page
    # which needs a bunch of API calls stubbed.
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/content/*})
      .to_return(body: {
        base_path: "/education/newly-created-taxon",
        content_id: "ID-4",
        document_type: "taxon",
        details: { internal_name: "Newly created taxon" },
        publication_state: "published",
        phase: "live",
        title: "Newly created taxon",
        state_history: {
          "1" => "published",
        },
      }.to_json)
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/links/*})
      .to_return(body: {}.to_json)
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/expanded-links/*})
      .to_return(body: { expanded_links: {} }.to_json)
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/linked/*})
      .to_return(body: {}.to_json)
    stub_email_requests_for_show_page

    click_on I18n.t("views.taxons.new_button")
  end

  def and_i_submit_the_taxon_with_a_taxon_with_semantic_issues_from_the_publishing_api
    fill_in :taxon_title, with: "My Taxon"
    fill_in :taxon_description, with: "Description of my taxon."
    fill_in :taxon_internal_name, with: "My Taxon"
    fill_in :taxon_base_path, with: "/foo/bar"

    # Before the taxon is created, we compare the old attributes with the new,
    # to create a diff. In this instance, a previous version does not exist.
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(status: 404)
    stub_request(:put, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(status: 422, body: {}.to_json)
    stub_request(:post, %r{https://publishing-api.test.gov.uk/lookup-by-base-path})
      .to_return(status: 200, body: {}.to_json)

    click_on I18n.t("views.taxons.new_button")
  end

  def and_i_submit_the_taxon_with_a_taxon_with_a_duplicate_base_path
    fill_in :taxon_title, with: "My Taxon"
    fill_in :taxon_description, with: "Description of my taxon."
    fill_in :taxon_internal_name, with: "My Taxon"
    fill_in :taxon_base_path, with: "/base-path"

    # Before the taxon is created, we compare the old attributes with the new,
    # to create a diff. In this instance, a previous version does not exist.
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(status: 404)
    stub_request(:put, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(status: 422, body: {}.to_json)
    stub_request(:post, %r{https://publishing-api.test.gov.uk/lookup-by-base-path})
      .with(body: hash_including(base_paths: ["/base-path"], with_drafts: true))
      .to_return(status: 200, body: {
        "/base-path" => SecureRandom.uuid,
      }.to_json)

    click_on I18n.t("views.taxons.new_button")
  end

  def then_i_can_see_a_generic_error_message
    expect(page).to have_selector(".alert", text: /there was a problem with your request/i)
  end

  def then_i_can_see_a_specific_error_message
    expect(page).to have_selector(".alert", text: /a taxon with this slug already exists/i)
  end

  def then_a_taxon_is_created
    expect(@create_item).to have_been_requested
    expect(@create_links).to have_been_requested
    expect(page).to have_content I18n.t("controllers.taxons.create_success")
  end

  def then_a_taxon_with_associated_taxons_is_created
    expect(@create_item).to have_been_requested
    expect(@create_links_with_associated_taxons).to have_been_requested
    expect(page).to have_content I18n.t("controllers.taxons.create_success")
  end

  def then_my_taxon_is_updated
    expect(@update_item).to have_been_requested
    expect(@create_links).to have_been_requested
  end

  def then_the_parent_is_correctly_prefilled
    expect(find("#taxon_parent_content_id").value).to eq("ID-1")
  end

  def and_my_taxon_is_not_published
    expect(@publish_item).not_to have_been_requested
  end

  def then_the_base_path_prefix_hint_is_updated
    expect(find(".js-path-prefix-hint")).to have_content "Base path must start with /transport"
  end

  def then_the_base_path_shows_as_invalid
    expect(page).to have_content "Base path must start with /transport"
  end

  def parent_taxon_json
    '[{ "internal_name": "foo", "content_id": "bar", "publication_state": "baz" }]'
  end

  def when_i_add_an_additional_legacy_taxon
    legacy_taxon_fields = all(:xpath, "//input[@name='taxon[legacy_taxons][]']")
    expect(legacy_taxon_fields[0].value).to eq "/legacy-taxon"
    legacy_taxon_fields[1].set("/another-legacy-taxon")
  end

  def then_the_legacy_taxons_should_be_saved
    stub_any_publishing_api_put_content
    stub_publishing_api_has_lookups(
      "/legacy-taxon" => "CONTENT-ID-LEGACY-TAXON",
      "/another-legacy-taxon" => "CONTENT-ID-ANOTHER-LEGACY-TAXON",
    )

    links_update_request = stub_publishing_api_patch_links(
      "ID-1",
      links: {
        root_taxon: [],
        parent_taxons: %w[ID-2],
        associated_taxons: [],
        legacy_taxons: %w[CONTENT-ID-LEGACY-TAXON CONTENT-ID-ANOTHER-LEGACY-TAXON],
      },
    )

    find(".submit-button").click

    expect(links_update_request).to have_been_requested
  end
end
