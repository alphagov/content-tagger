require "rails_helper"

RSpec.feature "Taxonomy editing" do
  include PublishingApiHelper
  include ContentItemHelper

  before do
    @taxon_1 = content_item_with_details(
      "I Am A Taxon",
      other_fields: {
        content_id: "ID-1",
        base_path: "/education/1",
        publication_state: 'published'
      }
    )
    @taxon_2 = content_item_with_details(
      "I Am Another Taxon",
      other_fields: {
        content_id: "ID-2",
        base_path: "/education/2",
        publication_state: 'published'
      }
    )
    @linkable_taxon_1 = {
      title: "I Am A Taxon",
      content_id: "ID-1",
      base_path: "/education/1",
      internal_name: "I Am A Taxon",
      publication_state: 'published'
    }
    @linkable_taxon_2 = {
      title: "I Am Another Taxon",
      content_id: "ID-2",
      base_path: "/education/2",
      internal_name: "I Am Another Taxon",
      publication_state: 'published'
    }

    @dummy_editor_notes = "Some usage notes for this taxon."

    @create_item = stub_request(:put, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(status: 200, body: {}.to_json)

    @create_links = stub_request(:patch, %r{https://publishing-api.test.gov.uk/v2/links*})
      .to_return(status: 200, body: {}.to_json)
  end

  scenario "User creates a taxon" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_new_taxon_button
    when_i_submit_the_taxon_with_a_title_and_parent
    then_a_taxon_is_created
  end

  scenario "User attempts to create a taxon that isn't semantically valid" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_new_taxon_button
    when_i_submit_the_taxon_with_a_taxon_with_semantic_issues
    then_i_can_see_a_generic_error_message
  end

  scenario "User attempts to create a taxon with a duplicate base path" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_new_taxon_button
    when_i_submit_the_taxon_with_a_taxon_with_a_duplicate_base_path
    then_i_can_see_a_specific_error_message
  end

  scenario "User edits a live taxon" do
    given_there_is_a_live_taxon
    and_i_visit_the_taxon_edit_page
    when_i_update_the_taxon
    then_my_taxon_is_updated
    and_my_taxon_is_automatically_published
  end

  scenario "User edits a draft taxon" do
    given_there_is_a_draft_taxon
    and_i_visit_the_taxon_edit_page
    when_i_update_the_taxon
    then_my_taxon_is_updated
    and_my_taxon_is_not_published
  end

  scenario "Taxon base path preview", js: true do
    given_there_are_taxons
    and_i_visit_the_taxon_edit_page
    when_i_change_the_path_slug
    then_the_base_path_preview_is_updated
  end

  def given_there_are_taxons
    publishing_api_has_linkables(
      [@linkable_taxon_1, @linkable_taxon_2],
      document_type: 'taxon'
    )
    publishing_api_has_taxons([@taxon_1, @taxon_2])

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/links/ID-1")
      .to_return(body: { links: { parent_taxons: [] } }.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-1")
      .to_return(body: @taxon_1.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-2")
      .to_return(body: @taxon_2.to_json)
  end

  def when_i_visit_the_taxonomy_page
    visit taxons_path
  end

  def and_i_click_on_the_new_taxon_button
    click_on I18n.t('views.taxons.add_taxon')
  end

  def fill_in_taxon_form
    fill_in :taxon_title, with: "My Lovely Taxon"
    fill_in :taxon_notes_for_editors, with: @dummy_editor_notes

    select @taxon_1[:title]
    expect(find('select').value).to include(@taxon_1[:content_id])

    select @taxon_2[:title]
    expect(find('select').value).to include(@taxon_2[:content_id])
  end

  def when_i_update_the_taxon
    fill_in :taxon_internal_name, with: "My updated taxon"
    fill_in :taxon_description, with: "Description of my updated taxon."
    fill_in :taxon_notes_for_editors, with: @dummy_editor_notes
    select "foo", from: "Parent"

    @update_item = stub_request(:put, %r{https://publishing-api.test.gov.uk/v2/content*})
      .with(body: /details.*#{@dummy_editor_notes}/)
      .to_return(status: 200, body: {}.to_json)

    @publish_item = stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/ID-1/publish")
      .to_return(status: 200, body: "", headers: {})

    publishing_api_has_expanded_links(
      content_id: @taxon_1[:content_id],
      expanded_links: {},
    )

    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/linked/*})
      .to_return(status: 200, body: {}.to_json)

    find('.submit-button').click
  end

  def given_there_is_a_live_taxon
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-1")
      .to_return(body: { content_id: "ID-1", base_path: "/foo", title: "Foo", publication_state: "published", details: { internal_name: "foo" } }.to_json)

    # dropdown of parent taxons
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linkables?document_type=taxon")
      .to_return(status: 200, body: parent_taxon_json, headers: {})

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/links/ID-1")
      .to_return(status: 200, body: "{}", headers: {})
  end

  def and_i_visit_the_taxon_edit_page
    visit edit_taxon_path("ID-1")
  end

  def given_there_is_a_draft_taxon
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-1")
      .to_return(body: { content_id: "ID-1", base_path: "/foo", title: "Foo", publication_state: "draft", details: { internal_name: "foo" } }.to_json)

    # dropdown of parent taxons
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linkables?document_type=taxon")
      .to_return(status: 200, body: parent_taxon_json, headers: {})

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/links/ID-1")
      .to_return(status: 200, body: "{}", headers: {})
  end

  def when_i_submit_the_taxon_with_a_title_and_parent
    # After the taxon is created we'll be redirected to the taxon's "view" page
    # which needs a bunch of API calls stubbed.
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/content/*})
      .to_return(body: { content_id: "", title: "Hey", base_path: "/foo", publication_state: "published", details: { internal_name: "Foo" } }.to_json)
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/links/*})
      .to_return(body: {}.to_json)
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/expanded-links/*})
      .to_return(body: { expanded_links: {} }.to_json)
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/linked/*})
      .to_return(body: {}.to_json)

    fill_in :taxon_title, with: "My Lovely Taxon"
    fill_in :taxon_description, with: "A description of my lovely taxon."
    fill_in :taxon_internal_name, with: "My Lovely Taxon"
    fill_in :taxon_notes_for_editors, with: @dummy_editor_notes
    find('select.js-path-prefix').find(:xpath, 'option[1]').select_option
    fill_in :taxon_path_slug, with: '/slug'

    select @taxon_1[:title]
    expect(find('select#taxon_parent').value).to eq(@taxon_1[:content_id])

    click_on I18n.t('views.taxons.new_button')
  end

  def when_i_submit_the_taxon_with_a_taxon_with_semantic_issues
    fill_in :taxon_title, with: 'My Taxon'
    fill_in :taxon_description, with: 'Description of my taxon.'
    fill_in :taxon_internal_name, with: 'My Taxon'
    find('select.js-path-prefix').find(:xpath, 'option[1]').select_option
    fill_in :taxon_path_slug, with: '/slug'

    stub_request(:put, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(status: 422, body: {}.to_json)
    stub_request(:post, %r{https://publishing-api.test.gov.uk/lookup-by-base-path})
      .to_return(status: 200, body: {}.to_json)

    click_on I18n.t('views.taxons.new_button')
  end

  def when_i_submit_the_taxon_with_a_taxon_with_a_duplicate_base_path
    fill_in :taxon_title, with: 'My Taxon'
    fill_in :taxon_description, with: 'Description of my taxon.'
    fill_in :taxon_internal_name, with: 'My Taxon'
    find('select.js-path-prefix').find(:xpath, 'option[2]').select_option
    fill_in :taxon_path_slug, with: '/ID-1'

    stub_request(:put, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(status: 422, body: {}.to_json)
    stub_request(:post, %r{https://publishing-api.test.gov.uk/lookup-by-base-path})
      .to_return(status: 200, body: {
        '/education/ID-1' => SecureRandom.uuid
      }.to_json)

    click_on I18n.t('views.taxons.new_button')
  end

  def when_i_change_the_path_slug
    fill_in :taxon_path_slug, with: '/changed-slug'
  end

  def then_i_can_see_a_generic_error_message
    expect(page).to have_selector('.alert', text: /there was a problem with your request/i)
  end

  def then_i_can_see_a_specific_error_message
    expect(page).to have_selector('.alert', text: /a taxon with this slug already exists/i)
  end

  def then_a_taxon_is_created
    expect(@create_item).to have_been_requested
    expect(@create_links).to have_been_requested
    expect(page).to have_content I18n.t('controllers.taxons.create_success')
  end

  def then_my_taxon_is_updated
    expect(@update_item).to have_been_requested
    expect(@create_links).to have_been_requested
  end

  def and_my_taxon_is_automatically_published
    expect(@publish_item).to have_been_requested
  end

  def and_my_taxon_is_not_published
    expect(@publish_item).not_to have_been_requested
  end

  def then_the_base_path_preview_is_updated
    expect(find('.js-base-path .base-path').text).to eql('/education/changed-slug')
  end

  def parent_taxon_json
    '[{ "internal_name": "foo", "content_id": "bar", "publication_state": "baz" }]'
  end
end
