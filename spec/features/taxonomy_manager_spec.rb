require "rails_helper"

RSpec.feature "Managing taxonomies" do
  include PublishingApiHelper
  before do
    @taxon_1 = {
      title: "I Am A Taxon",
      content_id: "ID-1",
      base_path: "/foo",
      internal_name: "I Am A Taxon",
      publication_state: 'active'
    }
    @taxon_2 = {
      title: "I Am Another Taxon",
      content_id: "ID-2",
      base_path: "/bar",
      internal_name: "I Am Another Taxon",
      publication_state: 'active'
    }

    @create_item = stub_request(:put, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(status: 200, body: {}.to_json)

    @publish_item = stub_request(:post, %r{https://publishing-api.test.gov.uk/v2/.*/publish})
      .to_return(status: 200, body: {}.to_json)

    @create_links = stub_request(:patch, %r{https://publishing-api.test.gov.uk/v2/links*})
      .to_return(status: 200, body: {}.to_json)
  end

  scenario "User creates a taxon with multiple parents" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_new_taxon_button
    when_i_submit_the_taxon_with_a_title_and_parents
    then_a_taxon_is_created
  end

  scenario "User attempts to create a taxon that isn't semantically valid" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_new_taxon_button
    when_i_submit_the_taxon_with_a_taxon_with_semantic_issues
    then_i_can_see_an_error_message
  end

  scenario "User edits a taxon" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_the_edit_taxon_link
    when_i_update_the_taxons_title_and_parents
    then_my_taxon_is_updated
  end

  scenario "Viewing tagged content of a taxon" do
    given_there_are_taxons
    and_theres_content_tagged_to_the_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_on_view_tagged_content
    then_i_see_tagged_content
  end

  scenario "Copy taxons" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_i_click_to_copy_taxons
    then_i_can_see_a_table_with_taxons_to_copy
  end

  def and_i_click_on_the_edit_taxon_link
    first('a', text: 'Edit taxon').click
    expect(page).to have_selector('.callout-warning', text: /editing/i)
  end

  def given_there_are_taxons
    publishing_api_has_linkables([@taxon_1, @taxon_2], document_type: 'taxon')
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
    click_on "Add a taxon"
    expect(page).to have_selector('.callout-info', text: /creating/i)
  end

  def fill_in_taxon_form
    fill_in :taxon_title, with: "My Lovely Taxon"

    select @taxon_1[:title]
    expect(find('select').value).to include(@taxon_1[:content_id])

    select @taxon_2[:title]
    expect(find('select').value).to include(@taxon_2[:content_id])
  end

  def when_i_update_the_taxons_title_and_parents
    fill_in_taxon_form
    click_on "Update taxon"
  end

  def when_i_submit_the_taxon_with_a_title_and_parents
    fill_in_taxon_form
    click_on "Create taxon"
  end

  def when_i_submit_the_taxon_with_a_taxon_with_semantic_issues
    fill_in :taxon_title, with: 'My Taxon'

    stub_request(:put, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(status: 422, body: {}.to_json)

    click_on "Create taxon"
  end

  def then_i_can_see_an_error_message
    expect(page).to have_selector('.alert', text: /there was a problem with your request/i)
  end

  def then_a_taxon_is_created
    expect(@create_item).to have_been_requested
    expect(@publish_item).to have_been_requested
    expect(@create_links).to have_been_requested
  end

  def then_my_taxon_is_updated
    then_a_taxon_is_created
  end

  def and_theres_content_tagged_to_the_taxons
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linked/ID-1?fields%5B%5D=base_path&fields%5B%5D=content_id&fields%5B%5D=document_type&fields%5B%5D=title&link_type=taxons")
      .to_return(body: [{ content_id: 'ID', title: 'Tagged Item', base_path: '/my/item', document_type: "guidance" }].to_json)
  end

  def and_i_click_on_view_tagged_content
    first('.view-tagged-content').click
  end

  def then_i_see_tagged_content
    expect(page).to have_content "Tagged Item"
  end

  def and_i_click_to_copy_taxons
    find_link('Copy taxons').click
  end

  def then_i_can_see_a_table_with_taxons_to_copy
    table = find('table')
    table_head = table.all('thead th').map(&:text)
    table_body = table.find('tbody').text

    expect(table_head).to include(/title/i)
    expect(table_head).to include(/content id/i)
    expect(table_head).to include(/link type/i)

    expect(table_body).to include(@taxon_1[:content_id])
    expect(table_body).to include(@taxon_1[:title])

    expect(table_body).to include(@taxon_2[:content_id])
    expect(table_body).to include(@taxon_2[:title])
    expect(table_body).to include('taxons')
  end
end
