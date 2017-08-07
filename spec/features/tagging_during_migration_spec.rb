require "rails_helper"

RSpec.describe "Tagging content during migration", type: :feature do
  include PublishingApiHelper

  before do
    given_we_can_populate_the_dropdowns_with_content_from_publishing_api
  end

  scenario "User makes a change to a content item which has had some of its link types disabled" do
    given_there_is_an_item_that_can_have_only_one_link_type

    when_i_visit_the_homepage
    and_i_submit_the_url_of_the_content_item

    when_i_add_an_additional_tag
    and_i_submit_the_form

    then_only_that_link_type_is_sent_to_the_publishing_api
  end

  def given_we_can_populate_the_dropdowns_with_content_from_publishing_api
    publishing_api_has_topic_linkables(
      [
        "/topic/id-of-already-tagged",
        "/topic/business-tax/pension-scheme-administration",
      ]
    )
    publishing_api_has_need_linkables(
      [
        "/needs/apply-for-a-copy-of-a-marriage-certificate",
      ]
    )
  end

  def given_there_is_an_item_that_can_have_only_one_link_type
    publishing_api_has_lookups(
      '/my-content-item' => 'MY-CONTENT-ID'
    )

    stub_request(:get, "#{PUBLISHING_API}/v2/content/MY-CONTENT-ID")
      .to_return(body: {
        # see blacklisted_tag_types.yml for this
        publishing_app: "test-app-that-can-be-tagged-to-topics-only",
        content_id: "MY-CONTENT-ID",
        base_path: '/my-content-item',
        document_type: 'mainstream_browse_page',
        title: 'This Is A Content Item',
      }.to_json)

    stub_request(:get, "#{PUBLISHING_API}/v2/expanded-links/MY-CONTENT-ID?generate=true")
      .to_return(body: {
        content_id: "MY-CONTENT-ID",
        expanded_links: {
          topics: [{ "content_id": "ID-OF-ALREADY-TAGGED" }],
          mainstream_browse_pages: [{ "content_id": "ID-OF-ALREADY-TAGGED-BROWSE-PAGE" }],
        },
        version: 54_321,
      }.to_json)
  end

  def when_i_visit_the_homepage
    visit root_path
  end

  def and_i_submit_the_url_of_the_content_item
    fill_in 'content_lookup_form_base_path', with: '/my-content-item'
    click_on I18n.t('taggings.search')
  end

  def when_i_add_an_additional_tag
    select "Business tax / Pension scheme administration", from: "Topics"
  end

  def and_i_submit_the_form
    @tagging_request = stub_request(:patch, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(status: 200)

    click_on I18n.t('taggings.update_tags')
  end

  def then_only_that_link_type_is_sent_to_the_publishing_api
    body = {
      links: {
        topics: ["e1d6b771-a692-4812-a4e7-7562214286ef", "ID-OF-ALREADY-TAGGED"],
      },
      previous_version: 54_321,
    }

    expect(@tagging_request.with(body: body.to_json)).to have_been_made
  end
end
