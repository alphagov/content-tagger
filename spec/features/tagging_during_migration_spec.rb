RSpec.describe "Tagging content during migration" do
  include PublishingApiHelper

  before do
    given_we_can_populate_the_dropdowns_with_content_from_publishing_api
  end

  scenario "User makes a change to a content item which has had some of its link types disabled" do
    given_there_is_an_item_that_can_have_only_one_link_type

    when_i_visit_edit_a_page
    and_i_submit_the_url_of_the_content_item

    when_i_add_an_additional_tag
    and_i_submit_the_form

    then_only_that_link_type_is_sent_to_the_publishing_api
  end

  def given_we_can_populate_the_dropdowns_with_content_from_publishing_api
    publishing_api_has_taxon_linkables(
      [
        "/alpha-taxonomy/vehicle-weights-explained",
        "/alpha-taxonomy/vehicle-plating",
      ],
    )
  end

  def given_there_is_an_item_that_can_have_only_one_link_type
    stub_publishing_api_has_lookups(
      "/my-content-item" => "MY-CONTENT-ID",
    )

    stub_request(:get, "#{Plek.find('publishing-api')}/v2/content/MY-CONTENT-ID")
      .to_return(body: {
        # see denylisted_tag_types.yml for this
        publishing_app: "test-app-that-can-be-tagged-to-taxons-only",
        content_id: "MY-CONTENT-ID",
        base_path: "/my-content-item",
        document_type: "mainstream_browse_page",
        title: "This Is A Content Item",
      }.to_json)

    stub_request(:get, "#{Plek.find('publishing-api')}/v2/expanded-links/MY-CONTENT-ID?generate=true")
      .to_return(body: {
        content_id: "MY-CONTENT-ID",
        expanded_links: {
          taxons: [{ "content_id": "4b5e77f7-69e5-45a9-9061-348cdce876fb" }],
          mainstream_browse_pages: [{ "content_id": "ID-OF-ALREADY-TAGGED-BROWSE-PAGE" }],
        },
        version: 54_321,
      }.to_json)
  end

  def when_i_visit_edit_a_page
    visit lookup_taggings_path
  end

  def and_i_submit_the_url_of_the_content_item
    fill_in "content_lookup_form_base_path", with: "/my-content-item"
    click_on I18n.t("taggings.search")
  end

  def when_i_add_an_additional_tag
    select "Vehicle plating", from: "Taxons"
  end

  def and_i_submit_the_form
    @tagging_request = stub_request(:patch, "#{Plek.find('publishing-api')}/v2/links/MY-CONTENT-ID")
      .to_return(status: 200)

    click_on I18n.t("taggings.update_tags")
  end

  def then_only_that_link_type_is_sent_to_the_publishing_api
    body = {
      links: {
        taxons: %w[17f91fdf-a36f-48f0-989c-a056d56876ee 4b5e77f7-69e5-45a9-9061-348cdce876fb],
      },
      previous_version: 54_321,
    }

    expect(@tagging_request.with(body: body.to_json)).to have_been_made
  end
end
