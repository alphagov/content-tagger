require "rails_helper"

RSpec.feature "Draft taxonomy" do
  include PublishingApiHelper
  include ContentItemHelper

  scenario "User can see draft taxons" do
    given_there_are_draft_taxons
    when_i_visit_the_draft_taxonomy_page
    then_i_can_see_the_draft_taxons
  end

  scenario "User can publish draft taxons" do
    given_there_is_a_draft_taxon
    when_i_visit_the_taxon_page
    and_i_click_the_publish_button
    and_i_confirm_that_i_want_to_publish
    then_the_taxon_should_be_published
  end

  scenario "User can discard draft taxons" do
    given_there_is_a_draft_taxon
    when_i_visit_the_taxon_page
    and_i_click_the_delete_link
    then_the_taxon_should_be_discarded
  end

  def given_there_are_draft_taxons
    @taxon_1 = content_item_with_details(
      "I Am A Taxon 1",
      other_fields: {
        content_id: "ID-1",
        base_path: "/foo",
        publication_state: 'active'
      }
    )
    @taxon_2 = content_item_with_details(
      "I Am Another Taxon 2",
      other_fields: {
        content_id: "ID-2",
        base_path: "/bar",
        publication_state: 'active'
      }
    )
    @taxon_3 = content_item_with_details(
      "I Am Yet Another Taxon 3",
      other_fields: {
        content_id: "ID-3",
        base_path: "/bar",
        publication_state: 'active'
      }
    )

    publishing_api_has_taxons(
      [@taxon_1, @taxon_2, @taxon_3],
      page: 1,
      states: ["draft"]
    )
  end

  def when_i_visit_the_draft_taxonomy_page
    visit drafts_taxons_path
  end

  def then_i_can_see_the_draft_taxons
    expect(page).to have_text(@taxon_1[:title])
    expect(page).to have_text(@taxon_2[:title])
    expect(page).to have_text(@taxon_3[:title])
  end

  def given_there_is_a_draft_taxon
    @taxon_content_id = SecureRandom.uuid
    @taxon = content_item_with_details(
      "Taxon 2",
      other_fields: {
        base_path: "/education/taxon-2",
        content_id: @taxon_content_id,
        description: 'A description of Taxon 2.',
        publication_state: 'draft',
      },
    )

    publishing_api_has_item(@taxon)
    publishing_api_has_links(
      content_id: @taxon_content_id,
      links: {}
    )

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/#{@taxon_content_id}")
      .to_return(status: 200, body: { expanded_links: {} }.to_json)
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linked/#{@taxon_content_id}?fields%5B%5D=base_path&fields%5B%5D=content_id&fields%5B%5D=document_type&fields%5B%5D=title&link_type=taxons")
      .to_return(status: 200, body: {}.to_json)
  end

  def when_i_visit_the_taxon_page
    visit taxon_path(@taxon_content_id)
  end

  def and_i_click_the_publish_button
    click_link "Publish"
  end

  def and_i_click_the_delete_link
    taxon = build(:taxon, publication_state: "draft")
    publishing_api_has_taxons([taxon])

    @discard_request = stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/#{@taxon_content_id}/discard-draft")
      .to_return(status: 200, body: "{}")

    click_on "Delete"
  end

  def and_i_confirm_that_i_want_to_publish
    @publish_request = stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/#{@taxon_content_id}/publish")
      .to_return(status: 200, body: "{}")

    click_button "Confirm publish"
  end

  def then_the_taxon_should_be_published
    expect(@publish_request).to have_been_requested
  end

  def then_the_taxon_should_be_discarded
    expect(@discard_request).to have_been_requested
  end
end
