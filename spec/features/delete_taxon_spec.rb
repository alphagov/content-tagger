require "rails_helper"

RSpec.feature "Delete Taxon", type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario "a taxon with no children" do
    given_a_taxon_with_no_children
    when_i_visit_the_taxon_page
    and_i_click_to_delete_the_taxon
    then_i_expect_to_be_informed_that_im_about_to_delete_the_taxon
    and_i_should_see_the_action_buttons
    and_i_click_delete
    then_i_expect_the_request_to_have_been_made
  end

  scenario "a parent taxon with children" do
    given_a_taxon_with_children
    when_i_visit_the_taxon_page
    then_i_expect_to_see_the_child_taxon
    and_i_click_to_delete_the_taxon
    then_i_should_see_a_warning_message
    and_i_should_see_the_action_buttons
    and_i_click_delete
    then_i_expect_the_request_to_have_been_made
  end

  def given_a_taxon_with_no_children
    @content_id = SecureRandom.uuid

    @taxon = {
      content_id: @content_id,
      title: 'Taxon 1',
      description: 'A description',
      base_path: 'A base path',
      publication_state: 'State',
      document_type: 'taxon',
      details: {
        internal_name: 'Internal name',
        notes_for_editors: 'Notes for editors',
      }
    }

    publishing_api_has_taxons(
      [@taxon],
      page: 1,
      per_page: 2,
    )

    publishing_api_has_item(@taxon)

    publishing_api_has_links(
      content_id: @content_id,
      links: {
        topics: [],
        parent_taxons: []
      }
    )

    publishing_api_has_linked_content_items(@content_id, "taxons", [@taxon])

    publishing_api_has_expanded_links(
      content_id: @content_id,
      expanded_links: {
        documents: []
      }
    )
  end

  def a_child_taxon
    @child_taxon_content_id = SecureRandom.uuid
    @child_taxon = {
      content_id: @child_taxon_content_id,
      title: 'A child taxon',
      description: 'a child taxon description',
      base_path: '/a/child/taxon/base/path',
      document_type: 'taxon',
      publication_state: 'State',
      details: {
        internal_name: 'Child Taxon',
        notes_for_editors: 'Notes for editors',
      }
    }

    publishing_api_has_links(
      content_id: @child_taxon_content_id,
      links: {
        topics: [],
        parent_taxons: [@content_id]
      }
    )

    publishing_api_has_linked_content_items(@content_id, "taxons", [@taxon, @child_taxon])
  end

  def given_a_taxon_with_children
    given_a_taxon_with_no_children
    a_child_taxon
  end

  def when_i_visit_the_taxon_page
    visit taxon_path(@content_id)
    expect(page).to have_text("Taxon")
  end

  def and_i_click_to_delete_the_taxon
    expect(page).to have_link("Delete taxon")
    click_on "Delete taxon"
  end

  def then_i_expect_to_be_informed_that_im_about_to_delete_the_taxon
    expect(page).to have_text('You are about to delete "Taxon 1"')
  end

  def and_i_should_see_the_action_buttons
    expect(page).to have_link('Cancel')
    expect(page).to have_link('I understand and I want to delete it')
  end

  def and_i_click_delete
    @unpublish_request = stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/#{@content_id}/unpublish")
      .with(body: "{\"type\":\"gone\"}").to_return(status: 200)

    # Because we'll end up on the taxons page
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content?document_type=taxon&order=-public_updated_at&page=1&per_page=50&q=")
      .to_return(body: "{\"total\": 0,\"pages\": 0,\"current_page\": 1,\"results\":[]}", status: 200)

    click_on "I understand and I want to delete it!"
  end

  def then_i_expect_the_request_to_have_been_made
    expect(@unpublish_request).to have_been_made
  end

  def then_i_expect_to_see_the_child_taxon
    expect(page).to have_text('A child taxon')
  end

  def then_i_should_see_a_warning_message
    expect(page).to have_text("Before you delete this taxon, make sure you've")
  end
end
