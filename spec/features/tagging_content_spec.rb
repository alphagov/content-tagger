require "rails_helper"

RSpec.describe "Tagging content" do
  scenario "User looks up and tags a content item" do
    given_there_is_a_content_item_with_tags

    when_i_visit_the_homepage
    and_i_submit_the_url_of_the_content_item
    then_i_am_on_the_page_for_an_item

    when_i_add_an_additional_tag
    and_i_submit_the_form
    then_the_new_links_are_sent_to_the_publishing_api
  end

  scenario "User looks up an untaggable page" do
    given_there_is_an_untaggable_page
    and_i_am_on_the_page_for_the_item
    then_i_see_that_the_page_is_untaggable
  end

  scenario "User makes a conflicting change" do
    given_there_is_a_content_item_with_tags
    and_i_am_on_the_page_for_the_item

    when_i_add_an_additional_tag
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
    given_there_is_a_content_item_with_tags
    when_i_type_its_basepath_in_the_url_directly
    then_i_am_on_the_page_for_the_item
  end

  before do
    setup_tags_for_select_boxes
  end

  def when_i_visit_the_homepage
    visit root_path
  end

  def when_i_type_its_basepath_in_the_url_directly
    visit "/lookup/my-content-item"
  end

  def and_i_am_on_the_page_for_the_item
    visit "/content/MY-CONTENT-ID"
  end

  def given_there_is_an_untaggable_page
    stub_request(:get, "#{PUBLISHING_API}/v2/content/MY-CONTENT-ID")
      .to_return(body: {
        publishing_app: "non-migrated-app",
        content_id: "MY-CONTENT-ID",
        base_path: '/my-content-item',
        format: 'mainstream_browse_page',
        title: 'This Is A Content Item',
      }.to_json)

    stub_request(:get, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(body: {}.to_json)
  end

  def given_there_is_a_content_item_with_tags
    publishing_api_has_lookups(
      '/my-content-item' => 'MY-CONTENT-ID'
    )

    stub_request(:get, "#{PUBLISHING_API}/v2/content/MY-CONTENT-ID")
      .to_return(body: {
        publishing_app: "a-migrated-app",
        content_id: "MY-CONTENT-ID",
        base_path: '/my-content-item',
        format: 'mainstream_browse_page',
        title: 'This Is A Content Item',
      }.to_json)

    stub_request(:get, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(body: {
        content_id: "MY-CONTENT-ID",
        links: {
          topics: "ID-OF-ALREADY-TAGGED",
        },
        version: 54_321,
      }.to_json)
  end

  def then_i_see_that_the_page_is_untaggable
    expect(page).to have_content "This page can't be tagged."
  end

  def and_i_submit_the_url_of_the_content_item
    fill_in 'content_lookup_form_base_path', with: '/my-content-item'
    click_on 'Show content item'
  end

  def and_i_fill_a_unknown_base_path_to_my_content_item
    # Publishing API returns nothing if the content item doesn't exist.
    publishing_api_has_lookups({})

    fill_in 'content_lookup_form_base_path', with: '/an-unknown-content-item'
    click_on 'Show content item'
  end

  def then_i_am_on_the_page_for_an_item
    expect(page).to have_content 'This Is A Content Item'
  end
  alias_method :then_i_am_on_the_page_for_the_item, :then_i_am_on_the_page_for_an_item

  def then_i_see_that_the_path_was_not_found
    expect(page).to have_content 'No page found with this path'
  end

  def when_i_add_an_additional_tag
    @tagging_request = stub_request(:patch, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(status: 200)

    select "Some Tag", from: "Topics"
  end

  def and_somebody_else_makes_a_change
    @tagging_request = stub_request(:patch, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(status: 409)
  end

  def then_i_see_that_there_is_a_conflict
    expect(page).to have_content 'Somebody changed the tags before you could'
  end

  def and_i_submit_the_form
    click_on 'Update tags'
  end

  def then_the_new_links_are_sent_to_the_publishing_api
    body = {
      links: {
        topics: ["ID-OF-FIRST-TAG", "ID-OF-ALREADY-TAGGED"],
        mainstream_browse_pages: [],
        organisations: [],
        alpha_taxons: [],
        parent: [],
      },
      previous_version: 54_321,
    }

    expect(@tagging_request.with(body: body.to_json)).to have_been_made
  end

  def setup_tags_for_select_boxes
    content = [
      {
        content_id: "ID-OF-FIRST-TAG",
        title: "Some Tag",
        publication_state: "published",
      },
      {
        content_id: "ID-OF-ALREADY-TAGGED",
        title: "Something Else",
        publication_state: "published",
      }
    ]

    %w(topic organisation mainstream_browse_page taxon).each do |document_type|
      publishing_api_has_linkables(content, document_type: document_type)
    end
  end
end
