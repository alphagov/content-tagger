require "rails_helper"

RSpec.describe "Tagging content with facets", type: :feature do
  include PublishingApiHelper

  before do
    stub_facet_groups_lookup
    given_we_can_populate_facets_with_content_from_publishing_api
  end

  scenario "User tags a content item with facet values" do
    given_there_is_a_content_item_with_expanded_links(
      facet_groups: [example_facet_group],
      facet_values: [example_facet_value],
    )
    when_i_visit_facet_groups_page
    and_i_select_the_facet_group("Example facet group")
    and_i_edit_facets_for_the_page("/my-content-item")
    and_i_see_the_facet_values_form_prefilled_with("Agriculture")

    when_i_select_an_additional_facet_value("Aerospace")

    and_i_submit_the_facets_tagging_form

    then_the_publishing_api_is_sent(
      facet_groups: ["abc-123"],
      facet_values: ["ANOTHER-FACET-VALUE-UUID", "EXISTING-FACET-VALUE-UUID"],
    )
  end

  def given_we_can_populate_facets_with_content_from_publishing_api
    publishing_api_has_facet_values_linkables(%w[Agriculture"])
  end

  def given_there_is_a_content_item_with_expanded_links(**expanded_links)
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
        expanded_links: expanded_links,
        version: 54_321,
      }.to_json)

    stub_facet_group_lookup
  end

  def when_i_visit_facet_groups_page
    visit facet_groups_path
  end

  def and_i_select_the_facet_group(name)
    click_link name
  end

  def and_i_edit_facets_for_the_page(path)
    fill_in 'content_lookup_form_base_path', with: path
    click_on 'Edit page'
  end

  def and_i_see_the_facet_values_form_prefilled_with(option)
    facet_values_options = all('#facets_tagging_update_form_facet_values option').map(&:text)
    expect(facet_values_options).to include(option)
  end

  def and_i_submit_the_facets_tagging_form
    click_on I18n.t('taggings.update_facets')
  end

  def when_i_select_an_additional_facet_value(selection)
    @facets_tagging_request = stub_request(:patch, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(status: 200)

    select selection, from: "Facet values"
  end

  def then_the_publishing_api_is_sent(**links)
    body = {
      links: links,
      previous_version: 54_321,
    }

    expect(@facets_tagging_request.with(body: body.to_json)).to have_been_made
  end
end
