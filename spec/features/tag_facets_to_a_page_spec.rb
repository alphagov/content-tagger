require "rails_helper"

RSpec.describe "Tagging content with facets", type: :feature do
  include PublishingApiHelper

  before do
    stub_facet_groups_lookup
    stub_patch_links_request("facets_tagging_request", "MY-CONTENT-ID")
    given_we_can_populate_facets_with_content_from_publishing_api
  end

  scenario "User tags a content item with facet values" do
    stub_finder_get_links_request
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
      "facets_tagging_request",
      links: {
        facet_groups: ["FACET-GROUP-UUID"],
        facet_values: ["ANOTHER-FACET-VALUE-UUID", "EXISTING-FACET-VALUE-UUID"],
      },
      previous_version: 54_321,
    )
  end

  scenario "User tags a content item with facet values and notifies users" do
    stub_finder_get_links_request
    stub_notification_request("notification_request", "MY-CONTENT-ID")

    given_there_is_a_content_item_with_expanded_links(
      facet_groups: [example_facet_group],
      facet_values: [example_facet_value],
    )
    when_i_visit_facet_groups_page
    and_i_select_the_facet_group("Example facet group")
    and_i_edit_facets_for_the_page("/my-content-item")
    and_i_see_the_facet_values_form_prefilled_with("Agriculture")

    when_i_select_an_additional_facet_value("Aerospace")
    and_i_opt_to_notify_users_with_the_message("Retagged!")

    and_i_submit_the_facets_tagging_form

    then_the_publishing_api_is_sent(
      "facets_tagging_request",
      links: {
        facet_groups: ["FACET-GROUP-UUID"],
        facet_values: ["ANOTHER-FACET-VALUE-UUID", "EXISTING-FACET-VALUE-UUID"],
      },
      previous_version: 54_321,
    )

    then_the_publishing_api_is_sent(
      "notification_request",
      publishing_app: "content-tagger",
      workflow_message: "Retagged!",
    )
  end

  scenario "User removes all facet values" do
    stub_finder_get_links_request
    given_there_is_a_content_item_with_expanded_links(
      facet_groups: [example_facet_group],
      facet_values: [example_facet_value],
    )
    when_i_visit_facet_groups_page
    and_i_select_the_facet_group("Example facet group")
    and_i_edit_facets_for_the_page("/my-content-item")
    and_i_see_the_facet_values_form_prefilled_with("Agriculture")

    when_i_remove_the_facet_value("Agriculture")

    and_i_submit_the_facets_tagging_form

    then_the_publishing_api_is_sent(
      "facets_tagging_request",
      links: {
        facet_groups: [],
        facet_values: [],
      },
      previous_version: 54_321,
    )
  end

  scenario "User makes a conflicting change" do
    stub_finder_get_links_request
    given_there_is_a_content_item_with_expanded_links(
      facet_groups: [example_facet_group],
      facet_values: [example_facet_value],
    )

    when_i_visit_facet_groups_page
    and_i_select_the_facet_group("Example facet group")
    and_i_edit_facets_for_the_page("/my-content-item")

    when_i_remove_the_facet_value("Agriculture")

    and_somebody_else_makes_a_change
    and_i_submit_the_facets_tagging_form

    then_i_see_that_there_is_a_conflict
  end

  # Pinning means the content item will be ordered above others in
  # filtered finder results. This means the item is added to the
  # ordered_related_items links for the finder.
  scenario "User pins a content item" do
    stub_finder_get_links_request
    stub_patch_links_request("finder_pinning_request", "FINDER-UUID")

    given_there_is_a_content_item_with_expanded_links(
      facet_groups: [example_facet_group],
      facet_values: [example_facet_value],
    )
    when_i_visit_facet_groups_page
    and_i_select_the_facet_group("Example facet group")
    and_i_edit_facets_for_the_page("/my-content-item")

    when_i_pin_the_item_in_finder_results

    and_i_submit_the_facets_tagging_form

    then_the_publishing_api_is_sent(
      "facets_tagging_request",
      links: {
        facet_groups: ["FACET-GROUP-UUID"],
        facet_values: ["EXISTING-FACET-VALUE-UUID"],
      },
      previous_version: 54_321,
    )

    then_the_publishing_api_is_sent(
      "finder_pinning_request",
      links: { ordered_related_items: ["EXISTING-PINNED-ITEM-UUID", "MY-CONTENT-ID"] }
    )
  end

  scenario "User unpins a content item" do
    stub_finder_get_links_request(items: ["EXISTING-PINNED-ITEM-UUID", "MY-CONTENT-ID"])
    stub_patch_links_request("finder_pinning_request", "FINDER-UUID")

    given_there_is_a_content_item_with_expanded_links(
      facet_groups: [example_facet_group],
      facet_values: [example_facet_value],
    )
    when_i_visit_facet_groups_page
    and_i_select_the_facet_group("Example facet group")
    and_i_edit_facets_for_the_page("/my-content-item")

    when_i_unpin_the_item_in_finder_results

    and_i_submit_the_facets_tagging_form

    then_the_publishing_api_is_sent(
      "facets_tagging_request",
      links: {
        facet_groups: ["FACET-GROUP-UUID"],
        facet_values: ["EXISTING-FACET-VALUE-UUID"],
      },
      previous_version: 54_321,
    )

    then_the_publishing_api_is_sent(
      "finder_pinning_request",
      links: { ordered_related_items: ["EXISTING-PINNED-ITEM-UUID"] }
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
    select selection, from: "Facet values"
  end

  def when_i_remove_the_facet_value(selection)
    unselect selection, from: "Facet values"
  end

  def when_i_pin_the_item_in_finder_results
    check 'facets_tagging_update_form_promoted'
  end

  def when_i_unpin_the_item_in_finder_results
    uncheck 'facets_tagging_update_form_promoted'
  end

  def stub_finder_get_links_request(content_id: "FINDER-UUID", items: ["EXISTING-PINNED-ITEM-UUID"])
    # Set the class as a local var otherwise RSpec confuses the interpreter
    # by defining `Facets::FinderService` as a module here.
    finder_service_class = Facets::FinderService
    stub_const "#{finder_service_class}::LINKED_FINDER_CONTENT_ID", content_id
    stub_request(:get, "#{PUBLISHING_API}/v2/links/#{content_id}")
      .to_return(
        status: 200,
        body: {
          links: {
            ordered_related_items: items
          }
        }.to_json
      )
  end

  def stub_patch_links_request(stub_request_name, content_id)
    instance_variable_set(
      "@#{stub_request_name}",
      stub_request(:patch, "#{PUBLISHING_API}/v2/links/#{content_id}")
        .to_return(status: 200)
    )
  end

  def stub_notification_request(stub_request_name, content_id)
    instance_variable_set(
      "@#{stub_request_name}",
      stub_request(
      :post, "#{PUBLISHING_API}/v2/content/#{content_id}/notify")
        .to_return(status: 200)
    )
  end

  def then_the_publishing_api_is_sent(stubbed_request_name, body)
    stubbed_request = instance_variable_get("@#{stubbed_request_name}")

    expect(stubbed_request.with(body: body.to_json)).to have_been_made
  end

  def and_somebody_else_makes_a_change
    @facets_tagging_request = stub_request(:patch, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(status: 409)
  end

  def then_i_see_that_there_is_a_conflict
    expect(page).to have_content 'Somebody changed the tags before you could'
  end

  def and_i_opt_to_notify_users_with_the_message(message)
    check "facets_tagging_update_form_notify"
    fill_in "facets_tagging_update_form_notification_message", with: message
  end

  def publishing_api_has_facet_values_linkables(labels)
    publishing_api_has_linkables(
      stubbed_facet_values.select { |fv| labels.include?(fv["title"]) },
      document_type: 'facet_value'
    )
  end

  def stub_facet_groups_lookup
    stub_request(:get, "#{PUBLISHING_API}/v2/content")
      .with(
        query: {
          document_type: "facet_group",
          order: "-public_updated_at",
          page: 1,
          per_page: 50,
          q: '',
          search_in: %w[title],
          states: %w[published]
        }
      )
      .to_return(body: { results: [example_facet_group] }.to_json)
  end

  def stub_finder_lookup(content_id = "FACET-GROUP-UUID")
    stub_request(:get, "#{PUBLISHING_API}/v2/linked/#{content_id}?document_type=finder")
      .to_return(body: [
        {
          content_id: content_id,
          base_path: "/some-finder",
        }
      ].to_json)
  end
end
