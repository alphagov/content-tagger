require "rails_helper"

RSpec.describe "Tagging content", type: :feature do
  include PublishingApiHelper

  before do
    given_we_can_populate_the_dropdowns_with_content_from_publishing_api
  end

  scenario "User looks up and tags a content item" do
    given_there_is_a_content_item_with_expanded_links(
      topics: [example_topic]
    )

    when_i_visit_the_homepage
    and_i_submit_the_url_of_the_content_item
    then_i_am_on_the_page_for_an_item
    and_the_expected_navigation_link_is_highlighted
    and_i_see_the_taxon_form

    when_i_select_an_additional_topic("Business tax / Pension scheme administration")
    and_i_submit_the_form

    then_the_publishing_api_is_sent(
      taxons: [],
      mainstream_browse_pages: [],
      parent: [],
      topics: ["e1d6b771-a692-4812-a4e7-7562214286ef", example_topic['content_id']],
      organisations: [],
    )
  end

  scenario "User tags a link type without existing tags" do
    given_there_is_a_content_item_with_no_expanded_links
    and_i_am_on_the_page_for_the_item

    when_i_select_an_additional_topic("Business tax / Pension scheme administration")
    and_i_submit_the_form

    then_the_publishing_api_is_sent(
      taxons: [],
      mainstream_browse_pages: [],
      parent: [],
      topics: ["e1d6b771-a692-4812-a4e7-7562214286ef"],
      organisations: [],
    )
  end

  scenario "User makes a conflicting change" do
    given_there_is_a_content_item_with_expanded_links(topics: [example_topic])
    and_i_am_on_the_page_for_the_item

    when_i_select_an_additional_topic("Business tax / Pension scheme administration")
    and_somebody_else_makes_a_change
    and_i_submit_the_form

    then_i_see_that_there_is_a_conflict
  end

  scenario "User inputs a URL that is not on GOV.UK" do
    when_i_visit_the_homepage
    and_i_fill_a_unknown_base_path_to_my_content_item
    then_i_see_that_the_path_was_not_found
  end

  scenario "User inputs a correct basepath directly in the URL" do
    given_there_is_a_content_item_with_expanded_links(topics: [example_topic])
    when_i_type_its_basepath_in_the_url_directly
    then_i_am_on_the_page_for_the_item
    and_the_expected_navigation_link_is_highlighted
  end

  def when_i_visit_the_homepage
    visit root_path
  end

  def when_i_type_its_basepath_in_the_url_directly
    visit "/taggings/lookup/my-content-item"
  end

  def and_i_am_on_the_page_for_the_item
    visit "/taggings/MY-CONTENT-ID"
  end

  def given_there_is_a_content_item_with_no_expanded_links
    # Stub the empty expanded links response
    given_there_is_a_content_item_with_expanded_links
  end

  def given_there_is_a_content_item_with_expanded_links(**expanded_links)
    publishing_api_has_lookups(
      '/my-content-item' => 'MY-CONTENT-ID'
    )

    stub_request(:get, "#{PUBLISHING_API}/v2/content/MY-CONTENT-ID")
      .to_return(body: {
        publishing_app: "a-migrated-app",
        content_id: "MY-CONTENT-ID",
        base_path: '/my-content-item',
        document_type: 'mainstream_browse_page',
        title: 'This Is A Content Item',
      }.to_json)

    stub_request(:get, "#{PUBLISHING_API}/v2/expanded-links/MY-CONTENT-ID")
      .to_return(body: {
        content_id: "MY-CONTENT-ID",
        expanded_links: expanded_links,
        version: 54_321,
      }.to_json)
  end

  def and_i_submit_the_url_of_the_content_item
    fill_in 'content_lookup_form_base_path', with: '/my-content-item'
    click_on I18n.t('taggings.search')
  end

  def and_i_fill_a_unknown_base_path_to_my_content_item
    # Publishing API returns nothing if the content item doesn't exist.
    publishing_api_has_lookups({})

    fill_in 'content_lookup_form_base_path', with: '/an-unknown-content-item'
    click_on I18n.t('taggings.search')
  end

  def then_i_am_on_the_page_for_an_item
    expect(page).to have_content 'This Is A Content Item'
  end
  alias_method :then_i_am_on_the_page_for_the_item, :then_i_am_on_the_page_for_an_item

  def and_the_expected_navigation_link_is_highlighted
    active_nav_link = find('.navbar-nav li.active')

    expect(active_nav_link.text).to match(I18n.t('navigation.tagging_content'))
  end

  def and_i_see_the_taxon_form
    taxon_options = all('#tagging_update_form_taxons option').map(&:text)
    expect(taxon_options).to include("Vehicle plating")
  end

  def then_i_see_that_the_path_was_not_found
    expect(page).to have_content 'No page found with this path'
  end

  def when_i_select_an_additional_topic(selection)
    @tagging_request = stub_request(:patch, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(status: 200)

    select selection, from: "Topics"
  end

  def and_somebody_else_makes_a_change
    @tagging_request = stub_request(:patch, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(status: 409)
  end

  def then_i_see_that_there_is_a_conflict
    expect(page).to have_content 'Somebody changed the tags before you could'
  end

  def and_i_submit_the_form
    click_on I18n.t('taggings.update_tags')
  end

  def then_the_publishing_api_is_sent(**links)
    body = {
      links: links,
      previous_version: 54_321,
    }

    expect(@tagging_request.with(body: body.to_json)).to have_been_made
  end

  def given_we_can_populate_the_dropdowns_with_content_from_publishing_api
    publishing_api_has_topic_linkables(
      [
        "/topic/id-of-already-tagged",
        "/topic/business-tax/pension-scheme-administration",
      ]
    )

    publishing_api_has_taxon_linkables(
      [
        "/alpha-taxonomy/vehicle-plating",
      ]
    )

    publishing_api_has_organisation_linkables(
      [
        "/government/organisations/student-loans-company",
      ]
    )

    publishing_api_has_mainstream_browse_page_linkables(
      [
        "/browse/driving/car-tax-discs",
      ]
    )
  end

  def example_topic
    {
      "content_id" => "ID-OF-ALREADY-TAGGED",
      "base_path" => "/already-tagged",
      "title" => "Already tagged",
    }
  end
end
