require "rails_helper"

RSpec.describe "Tagging content", type: :feature do
  include PublishingApiHelper

  before do
    given_we_can_populate_the_dropdowns_with_content_from_publishing_api
  end

  scenario "User tags a page with related content item" do
    given_a_content_item_exists
    and_i_navigate_to_tagging_page_for_item
    when_i_add_a_valid_related_content_item_path
    and_i_submit_the_form
    then_the_publishing_api_is_sent_the_related_item
  end

  scenario "User tries to tag a content item with a non-existent related item" do
    given_a_content_item_exists
    and_i_navigate_to_tagging_page_for_item
    when_i_add_a_path_which_does_not_match_a_content_item
    and_i_submit_the_form
    then_i_see_an_error_for_the_missing_path
  end

  def then_the_publishing_api_is_sent(**links)
    body = {
      links: links,
      previous_version: 54_321,
    }

    expect(@tagging_request.with(body: body.to_json)).to have_been_made
  end

  def and_i_navigate_to_tagging_page_for_item
    visit "/taggings/MY-CONTENT-ID"
  end

  def given_a_content_item_exists
    publishing_api_has_lookups(
      '/my-content-item' => 'MY-CONTENT-ID'
    )

    stub_request(:get, "#{PUBLISHING_API}/v2/content/MY-CONTENT-ID")
      .to_return(body: {
        publishing_app: "a-migrated-app",
        rendering_app: "frontend",
        content_id: "MY-CONTENT-ID",
        base_path: '/my-content-item',
        document_type: 'guide',
        title: 'This Is A Content Item',
      }.to_json)

    stub_request(:get, "#{PUBLISHING_API}/v2/expanded-links/MY-CONTENT-ID?generate=true")
      .to_return(body: {
        content_id: "MY-CONTENT-ID",
        expanded_links: {},
        version: 54_321,
      }.to_json)
  end

  def given_we_can_populate_the_dropdowns_with_content_from_publishing_api
    # In this test we don't care about empty dropdowns
    %w[topic taxon organisation mainstream_browse_page need].each do |document_type|
      publishing_api_has_linkables([], document_type: document_type)
    end
  end

  def when_i_add_a_valid_related_content_item_path
    stub_request(:post, "https://publishing-api.test.gov.uk/lookup-by-base-path")
      .with(body: { "base_paths" => ["/pay-vat"] })
      .to_return(body: { "/pay-vat" => "a484eaea-eeb6-48fa-92a7-b67c6cd414f6" }.to_json)

    @tagging_request = stub_request(:patch, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(status: 200)

    related_items = all(:xpath, "//input[@name='tagging_tagging_update_form[ordered_related_items][]']")
    related_items[0].set("/pay-vat")
  end

  def when_i_add_a_path_which_does_not_match_a_content_item
    stub_request(:post, "https://publishing-api.test.gov.uk/lookup-by-base-path")
      .with(body: { "base_paths" => ["/pay-vat", "/no-such-path"] })
      .to_return(body: { "/pay-vat" => "a484eaea-eeb6-48fa-92a7-b67c6cd414f6" }.to_json)

    related_items = all(:xpath, "//input[@name='tagging_tagging_update_form[ordered_related_items][]']")
    related_items[1].set("/no-such-path")
  end

  def then_i_see_an_error_for_the_missing_path
    expect(page).to have_content 'Not a known URL on GOV.UK: /no-such-path'
    expect(page).not_to have_content 'Not a known URL on GOV.UK: /pay-vat'
  end

  def and_i_submit_the_form
    click_on I18n.t('taggings.update_tags')
  end

  def then_the_publishing_api_is_sent_the_related_item
    then_the_publishing_api_is_sent(
      taxons: [],
      ordered_related_items: ['a484eaea-eeb6-48fa-92a7-b67c6cd414f6'],
      mainstream_browse_pages: [],
      parent: [],
      topics: [],
      organisations: [],
      meets_user_needs: [],
    )
  end
end
