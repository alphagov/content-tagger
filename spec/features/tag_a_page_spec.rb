RSpec.describe "Tagging content" do
  include PublishingApiHelper

  before do
    given_we_can_populate_the_dropdowns_with_content_from_publishing_api
  end

  scenario "User looks up and tags a content item" do
    given_there_is_a_content_item_with_expanded_links(
      topics: [example_topic],
    )

    when_i_visit_edit_a_page
    and_i_submit_the_url_of_the_content_item
    then_i_am_on_the_page_for_an_item
    and_the_expected_navigation_link_is_highlighted
    and_i_see_the_taxon_form

    when_i_select_an_additional_topic("Business tax / Pension scheme administration")
    and_i_submit_the_form

    then_the_publishing_api_is_sent(
      taxons: [],
      ordered_related_items: [],
      mainstream_browse_pages: [],
      parent: [],
      topics: ["e1d6b771-a692-4812-a4e7-7562214286ef", example_topic["content_id"]],
      organisations: [],
      meets_user_needs: [],
    )
  end

  scenario "User tags a link type without existing tags" do
    given_there_is_a_content_item_with_no_expanded_links
    and_i_am_on_the_page_for_the_item

    when_i_select_an_additional_topic("Business tax / Pension scheme administration")
    and_i_submit_the_form

    then_the_publishing_api_is_sent(
      taxons: [],
      ordered_related_items: [],
      mainstream_browse_pages: [],
      parent: [],
      topics: %w[e1d6b771-a692-4812-a4e7-7562214286ef],
      organisations: [],
      meets_user_needs: [],
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
    when_i_visit_edit_a_page
    and_i_fill_a_unknown_base_path_to_my_content_item
    then_i_see_that_the_path_was_not_found
  end

  scenario "User inputs a correct basepath directly in the URL" do
    given_there_is_a_content_item_with_expanded_links(topics: [example_topic])
    when_i_type_its_basepath_in_the_url_directly
    then_i_am_on_the_page_for_the_item
    and_the_expected_navigation_link_is_highlighted
  end

  context "with javascript disabled", type: :feature, js: false do
    scenario "the user sets a new related link" do
      given_there_is_a_content_item_with_expanded_links(ordered_related_items: [example_topic])
      stub_publishing_api_has_lookups(
        example_topic["base_path"] => example_topic["content_id"],
        "/pay-vat" => "a484eaea-eeb6-48fa-92a7-b67c6cd414f6",
      )
      and_i_am_on_the_page_for_the_item
      when_i_fill_in_related_items(2 => "/pay-vat")
      and_i_submit_the_form

      then_the_publishing_api_is_sent(
        taxons: [],
        ordered_related_items: [example_topic["content_id"], "a484eaea-eeb6-48fa-92a7-b67c6cd414f6"],
        mainstream_browse_pages: [],
        parent: [],
        topics: [],
        organisations: [],
        meets_user_needs: [],
      )
    end

    scenario "the user sets an invalid related link" do
      given_there_is_a_content_item_with_expanded_links(ordered_related_items: [example_topic])
      stub_publishing_api_has_lookups(
        example_topic["base_path"] => example_topic["content_id"],
      )
      and_i_am_on_the_page_for_the_item
      when_i_fill_in_related_items(2 => "/pay-cat")
      and_i_submit_the_form

      then_i_am_on_the_page_for_the_item
      and_i_see_the_url_is_invalid
    end

    scenario "the user sets a new valid and invalid related link" do
      given_there_is_a_content_item_with_expanded_links(ordered_related_items: [example_topic])
      stub_publishing_api_has_lookups(
        example_topic["base_path"] => example_topic["content_id"],
        "/pay-vat" => "a484eaea-eeb6-48fa-92a7-b67c6cd414f6",
      )
      and_i_am_on_the_page_for_the_item
      when_i_fill_in_related_items(2 => "/pay-vat", 3 => "/pay-cat")
      and_i_submit_the_form

      then_i_am_on_the_page_for_the_item
      and_i_see_the_url_is_invalid
      and_the_related_items_should_be_prefilled_with(2 => "/pay-vat", 3 => "/pay-cat")
    end

    scenario "the user changes a suggested related link to be invalid" do
      given_there_is_a_content_item_with_expanded_links(suggested_ordered_related_items: [example_topic])
      stub_publishing_api_has_lookups(
        example_topic["base_path"] => example_topic["content_id"],
      )
      and_i_am_on_the_page_for_the_item
      when_i_fill_in_related_items(6 => "/pay-cat")
      and_i_submit_the_form

      then_i_am_on_the_page_for_the_item
      and_i_see_the_url_is_invalid
    end

    scenario "the user removes suggested related links" do
      given_there_is_a_content_item_with_expanded_links(suggested_ordered_related_items: [example_topic])
      stub_publishing_api_has_lookups(
        example_topic["base_path"] => example_topic["content_id"],
        "/pay-vat" => "a484eaea-eeb6-48fa-92a7-b67c6cd414f6",
      )
      and_i_am_on_the_page_for_the_item
      when_i_fill_in_related_items(6 => "")
      and_i_submit_the_form
      then_the_publishing_api_is_sent(
        taxons: [],
        ordered_related_items: [],
        suggested_ordered_related_items: [],
        mainstream_browse_pages: [],
        parent: [],
        topics: [],
        organisations: [],
        meets_user_needs: [],
      )
    end

    scenario "the user does not see suggested related links when no suggested links exist" do
      given_there_is_a_content_item_with_expanded_links(ordered_related_items: [])
      stub_publishing_api_has_lookups(
        example_topic["base_path"] => example_topic["content_id"],
        "/pay-vat" => "a484eaea-eeb6-48fa-92a7-b67c6cd414f6",
      )
      and_i_am_on_the_page_for_the_item

      then_the_suggested_related_items_component_should_not_be_shown
    end
  end

  def when_i_visit_edit_a_page
    visit lookup_taggings_path
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
    stub_publishing_api_has_lookups(
      "/my-content-item" => "MY-CONTENT-ID",
    )

    stub_request(:get, "#{Plek.find('publishing-api')}/v2/content/MY-CONTENT-ID")
      .to_return(body: {
        publishing_app: "a-migrated-app",
        rendering_app: "frontend",
        content_id: "MY-CONTENT-ID",
        base_path: "/my-content-item",
        document_type: "guide",
        title: "This Is A Content Item",
      }.to_json)

    stub_request(:get, "#{Plek.find('publishing-api')}/v2/expanded-links/MY-CONTENT-ID?generate=true")
      .to_return(body: {
        content_id: "MY-CONTENT-ID",
        expanded_links:,
        version: 54_321,
      }.to_json)
  end

  def and_i_submit_the_url_of_the_content_item
    fill_in "content_lookup_form_base_path", with: "/my-content-item"
    click_on I18n.t("taggings.search")
  end

  def and_i_fill_a_unknown_base_path_to_my_content_item
    # Publishing API returns nothing if the content item doesn't exist.
    stub_publishing_api_has_lookups({})

    fill_in "content_lookup_form_base_path", with: "/an-unknown-content-item"
    click_on I18n.t("taggings.search")
  end

  def when_i_fill_in_related_items(values)
    @tagging_request = stub_request(:patch, "#{Plek.find('publishing-api')}/v2/links/MY-CONTENT-ID")
      .to_return(status: 200)

    fields = all(".related-item input")
    values.each do |i, value|
      fields[i].set(value)
    end
  end

  def and_the_related_items_should_be_prefilled_with(values)
    fields = all(".related-item input")
    values.each do |i, value|
      expect(fields[i].value).to eq(value)
    end
  end

  def then_the_suggested_related_items_component_should_not_be_shown
    expect(page).not_to have_content "Suggested related content items"
  end

  def then_i_am_on_the_page_for_an_item
    expect(page).to have_content "This Is A Content Item"
  end
  alias_method :then_i_am_on_the_page_for_the_item, :then_i_am_on_the_page_for_an_item

  def and_the_expected_navigation_link_is_highlighted
    active_nav_link = find(".navbar-nav li.active")

    expect(active_nav_link.text).to match(I18n.t("navigation.tagging_content"))
  end

  def and_i_see_the_taxon_form
    taxon_options = all("#tagging_tagging_update_form_taxons option").map(&:text)
    expect(taxon_options).to include("Vehicle plating")
  end

  def then_i_see_that_the_path_was_not_found
    expect(page).to have_content "No page found with this path"
  end

  def and_i_see_the_url_is_invalid
    expect(page).to have_content "Not a known URL on GOV.UK"
  end

  def when_i_select_an_additional_topic(selection)
    @tagging_request = stub_request(:patch, "#{Plek.find('publishing-api')}/v2/links/MY-CONTENT-ID")
      .to_return(status: 200)

    select selection, from: "Topics"
  end

  def and_somebody_else_makes_a_change
    @tagging_request = stub_request(:patch, "#{Plek.find('publishing-api')}/v2/links/MY-CONTENT-ID")
      .to_return(status: 409)
  end

  def then_i_see_that_there_is_a_conflict
    expect(page).to have_content "Somebody changed the tags before you could"
  end

  def and_i_submit_the_form
    click_on I18n.t("taggings.update_tags")
  end

  def then_the_publishing_api_is_sent(**links)
    body = {
      links:,
      previous_version: 54_321,
    }

    expect(@tagging_request.with(body: body.to_json)).to have_been_made
  end

  def given_we_can_populate_the_dropdowns_with_content_from_publishing_api
    publishing_api_has_topic_linkables(
      [
        "/topic/id-of-already-tagged",
        "/topic/business-tax/pension-scheme-administration",
      ],
    )

    publishing_api_has_taxon_linkables(
      [
        "/alpha-taxonomy/vehicle-plating",
      ],
    )

    publishing_api_has_organisation_linkables(
      [
        "/government/organisations/student-loans-company",
      ],
    )

    publishing_api_has_need_linkables(
      [
        "/needs/apply-for-a-copy-of-a-marriage-certificate",
      ],
    )

    publishing_api_has_mainstream_browse_page_linkables(
      [
        "/browse/driving/car-tax-discs",
      ],
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
