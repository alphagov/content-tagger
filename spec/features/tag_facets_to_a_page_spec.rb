require "rails_helper"

RSpec.describe "Tagging content with facets", type: :feature do
  include PublishingApiHelper

  before do
    stub_facet_groups_lookup
    stub_publishing_api_has_links(content_id: "MY-CONTENT-ID", links: { ordered_related_items: [] })
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
        finder: [stub_linked_finder_content_id],
        ordered_related_items: [stub_linked_finder_content_id],
      },
      previous_version: 54_321,
    )
  end

  scenario "User tags a content item with facet values and notifies users" do
    Timecop.freeze("2019-04-12T15:05:59+00:00") do
      stub_finder_get_links_request
      stub_notification_request
      expected_links = {
        facet_groups: ["FACET-GROUP-UUID"],
        facet_values: ["ANOTHER-FACET-VALUE-UUID", "EXISTING-FACET-VALUE-UUID"],
        finder: [stub_linked_finder_content_id],
        ordered_related_items: [stub_linked_finder_content_id],
      }

      expected_tags = {
        "appear_in_find_eu_exit_guidance_business_finder" => "yes"
      }

      given_there_is_a_content_item_with_expanded_links(
        facet_groups: [example_facet_group],
        facet_values: [example_facet_value],
      )
      when_i_visit_facet_groups_page
      and_i_select_the_facet_group("Example facet group")
      and_i_edit_facets_for_the_page("/my-content-item")
      and_i_see_the_facet_values_form_prefilled_with("Agriculture")

      when_i_select_an_additional_facet_value("Aerospace")
      and_i_opt_to_notify_users
      and_i_fill_in_the_notification_message_with("Retagged!")

      and_i_submit_the_facets_tagging_form

      then_the_publishing_api_is_sent(
        "facets_tagging_request",
        links: expected_links,
        previous_version: 54_321,
      )

      and_the_email_alert_api_is_sent(
        base_path: "/my-content-item",
        change_note: "Retagged!",
        content_id: "MY-CONTENT-ID",
        description: "Describes my content item",
        document_type: "guide",
        email_document_supertype: "other",
        government_document_supertype: "other",
        links: expected_links,
        priority: "high",
        public_updated_at: "2019-04-12T15:05:59+00:00",
        publishing_app: "content-tagger",
        subject: 'This Is A Content Item',
        tags: expected_tags,
        title: 'This Is A Content Item',
        urgent: true,
      )
    end
  end

  scenario "User tags a content item and notifies users without a message" do
    stub_finder_get_links_request
    stub_notification_request

    given_there_is_a_content_item_with_expanded_links(
      facet_groups: [example_facet_group],
      facet_values: [example_facet_value],
    )
    when_i_visit_facet_groups_page
    and_i_select_the_facet_group("Example facet group")
    and_i_edit_facets_for_the_page("/my-content-item")
    and_i_see_the_facet_values_form_prefilled_with("Agriculture")

    when_i_select_an_additional_facet_value("Aerospace")
    and_i_opt_to_notify_users

    and_i_submit_the_facets_tagging_form

    then_the_publishing_api_is_sent(
      "facets_tagging_request",
      links: {
        facet_groups: ["FACET-GROUP-UUID"],
        facet_values: ["ANOTHER-FACET-VALUE-UUID", "EXISTING-FACET-VALUE-UUID"],
        finder: [stub_linked_finder_content_id],
        ordered_related_items: [stub_linked_finder_content_id],
      },
      previous_version: 54_321,
    )
    and_i_see_the_notification_is_invalid
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
        finder: [],
        ordered_related_items: [],
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
        description: 'Describes my content item',
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
    facet_values_options = all('#facets_tagging_update_form_example_facet option').map(&:text)
    expect(facet_values_options).to include(option)
  end

  def and_i_submit_the_facets_tagging_form
    click_on I18n.t('taggings.update_facets')
  end

  def when_i_select_an_additional_facet_value(selection)
    select selection, from: "facets_tagging_update_form_example_facet"
  end

  def when_i_remove_the_facet_value(selection)
    unselect selection, from: "facets_tagging_update_form_example_facet"
  end

  def and_i_see_the_notification_is_invalid
    within(".facets_tagging_update_form_notification_message") do
      expect(page).to have_css("#facets_tagging_update_form_notification_message[aria-invalid='true']")
    end
  end

  def stub_finder_get_links_request(items: ["EXISTING-PINNED-ITEM-UUID"])
    stub_request(:get, "#{PUBLISHING_API}/v2/links/#{stub_linked_finder_content_id}")
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

  def stub_notification_request
    @notification_request = stub_email_alert_api_accepts_content_change
  end

  def then_the_publishing_api_is_sent(stubbed_request_name, body)
    stubbed_request = instance_variable_get("@#{stubbed_request_name}")

    expect(stubbed_request.with(body: body.to_json)).to have_been_made
  end

  def and_the_email_alert_api_is_sent(body)
    expect(@notification_request.with(body: body.to_json)).to have_been_made
  end

  def and_somebody_else_makes_a_change
    @facets_tagging_request = stub_request(:patch, "#{PUBLISHING_API}/v2/links/MY-CONTENT-ID")
      .to_return(status: 409)
  end

  def then_i_see_that_there_is_a_conflict
    expect(page).to have_content 'Somebody changed the tags before you could'
  end

  def and_i_opt_to_notify_users
    check "facets_tagging_update_form_notify"
  end

  def and_i_fill_in_the_notification_message_with(message)
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

  def stub_linked_finder_content_id
    # Set the class as a local var otherwise RSpec confuses the interpreter
    # by defining `Facets::FinderService` as a module here.
    finder_service_class = Facets::FinderService
    stub_const "#{finder_service_class}::LINKED_FINDER_CONTENT_ID", "FINDER-UUID"
  end
end
