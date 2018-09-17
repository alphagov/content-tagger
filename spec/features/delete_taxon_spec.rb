require "rails_helper"

RSpec.feature "Delete Taxon", type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario "deleting a taxon with no children or tagged content" do
    given_a_taxon_with_no_children
    when_i_visit_the_taxon_page
    when_i_click_unpublish_taxon
    then_i_see_a_basic_prompt_to_delete
    then_i_see_a_list_of_taxons_to_redirect_to
    when_i_choose_a_taxon_to_redirect_to("Vehicle plating")
    when_i_confirm_deletion
    then_the_taxon_is_deleted
  end

  scenario "deleting a taxon with children" do
    given_a_taxon_with_children
    when_i_visit_the_taxon_page
    then_i_expect_to_see_the_child_taxon
    when_i_click_unpublish_taxon
    then_i_see_a_prompt_to_delete_with_a_warning_message
    then_i_see_a_list_of_taxons_to_redirect_to
    when_i_choose_a_taxon_to_redirect_to("Vehicle plating")
    when_i_confirm_deletion
    then_the_taxon_is_deleted
  end

  scenario "deleting a taxon with tagged content" do
    given_a_taxon_with_tagged_content
    when_i_visit_the_taxon_tagged_content_page
    then_i_expect_to_see_the_tagged_content
    when_i_visit_the_taxon_page
    when_i_click_unpublish_taxon
    then_i_see_a_prompt_to_delete_with_a_warning_message
    then_i_see_a_list_of_taxons_to_redirect_to
    when_i_choose_a_taxon_to_redirect_to("Vehicle plating")
    when_i_confirm_deletion
    then_the_taxon_is_deleted
  end

  scenario "deleting a taxon with tagged content that has a parent" do
    given_a_taxon_with_a_parent_and_tagged_content
    when_i_visit_the_taxon_tagged_content_page
    then_i_expect_to_see_the_tagged_content
    when_i_visit_the_taxon_page
    when_i_click_unpublish_taxon
    then_i_see_a_prompt_to_delete_with_a_warning_message
    then_i_see_a_list_of_taxons_to_redirect_to
    when_i_choose_a_taxon_to_redirect_to("Vehicle plating")
    when_i_confirm_deletion
    then_the_taxon_is_deleted
    and_the_tagged_content_is_tagged_to_the_parent
  end

  scenario "deleting a taxon with tagged content that has a parent and unchecking the tagging checkbox" do
    given_a_taxon_with_a_parent_and_tagged_content
    when_i_visit_the_taxon_tagged_content_page
    then_i_expect_to_see_the_tagged_content
    when_i_visit_the_taxon_page
    when_i_click_unpublish_taxon
    then_i_see_a_prompt_to_delete_with_a_warning_message
    then_i_see_a_list_of_taxons_to_redirect_to
    when_i_choose_a_taxon_to_redirect_to("Vehicle plating")
    uncheck('taxonomy_delete_page_do_tag')
    when_i_confirm_deletion
    then_the_taxon_is_deleted
    and_no_content_is_tagged_to_the_parent
  end

  scenario "restoring a deleted taxon" do
    given_a_deleted_taxon
    when_i_visit_the_taxon_page
    when_i_click_restore_taxon
    then_i_see_a_prompt_to_restore_with_an_informative_message
    when_i_confirm_restoration
    then_the_taxon_is_restored
  end

  def given_a_taxon_with_no_children
    @taxon_content_id = SecureRandom.uuid
    @taxon = taxon_with_details(
      "Taxon 1",
      other_fields: {
        content_id: @taxon_content_id,
        state_history: {
          "1" => "published"
        }
      }
    )

    stub_requests_for_show_page(@taxon)
  end

  def given_a_taxon_with_children
    given_a_taxon_with_no_children
    add_a_child_taxon
  end

  def given_a_taxon_with_tagged_content
    given_a_taxon_with_no_children
    add_tagged_content(fields: %w[base_path content_id document_type title])
  end

  def given_a_taxon_with_a_parent_and_tagged_content
    given_a_taxon_with_no_children
    add_a_parent_taxon
    add_tagged_content_to_parent
    add_tagged_content(fields: %w[base_path content_id document_type title])
    add_tagged_content(fields: %w[base_path])
  end

  def given_a_deleted_taxon
    @taxon_content_id = SecureRandom.uuid
    @taxon = taxon_with_details(
      "Taxon 2",
      other_fields: {
        base_path: "/level-one/taxon-2",
        content_id: @taxon_content_id,
        description: 'A description of Taxon 2.',
        state_history: {
          "1" => "unpublished"
        }
      },
      unpublished: true
    )

    stub_requests_for_show_page(@taxon)

    # Override the `links` call in stub_requests_for_show_page
    # TODO: extend stub_requests_for_show_page to make this easier
    publishing_api_has_links(
      content_id: @taxon_content_id,
      links: {
        parent_taxons: ['CONTENT-ID-PARENT'],
        associated_taxons: %w[1234],
      }
    )
  end

  def when_i_visit_the_taxon_page
    visit taxon_path(@taxon_content_id)
  end

  def when_i_visit_the_taxon_tagged_content_page
    visit taxon_tagged_content_path(@taxon_content_id)
  end

  def when_i_click_unpublish_taxon
    publishing_api_has_taxon_linkables(
      [
        "/alpha-taxonomy/vehicle-plating",
        "/alpha-taxonomy/vehicle-weights-explained",
      ]
    )
    click_on "Unpublish"
  end

  def when_i_click_restore_taxon
    click_link "Restore"
  end

  def then_i_see_a_basic_prompt_to_delete
    expect(page).to have_text('You are about to delete "Taxon 1"')
    expect(page).to_not have_text("Before you delete this taxon, make sure you've")
    expect(page).to have_link('Cancel')
    expect(page).to have_button('Delete and redirect')
  end

  def then_i_see_a_list_of_taxons_to_redirect_to
    expect(page).to have_select "Redirect to", options: [
      '',
      'Vehicle plating',
    ]
  end

  def when_i_choose_a_taxon_to_redirect_to(selection)
    select selection, from: "Redirect to"
  end

  def when_i_confirm_deletion
    Sidekiq::Testing.inline! do
      @get_content_request = publishing_api_has_item(stubbed_taxons[0])
      @unpublish_request = stub_publishing_api_unpublish(@taxon_content_id, body: { type: :redirect, alternative_path: "/alpha-taxonomy/vehicle-plating" }.to_json)
      click_on "Delete and redirect"
    end
  end

  def when_i_confirm_restoration
    parent_taxon = taxon_with_details(
      'root', other_fields: { base_path: '/level-one', content_id: 'CONTENT-ID-PARENT' }
    )
    publishing_api_has_item(parent_taxon)
    publishing_api_has_links(content_id: 'CONTENT-ID-PARENT')

    @put_content_request = stub_publishing_api_put_content(@taxon_content_id, {})
    @patch_links_request = stub_publishing_api_patch_links(@taxon_content_id, {})
    click_on "Confirm restore"
  end

  def then_the_taxon_is_deleted
    expect(@unpublish_request).to have_been_made
  end

  def then_the_taxon_is_restored
    expect(@put_content_request).to have_been_made
    expect(@patch_links_request).to have_been_made

    # This is the taxons index page and not the trash page
    expect(page).to have_content @taxon.fetch(:title)
  end

  def then_i_expect_to_see_the_child_taxon
    within(".taxonomy-tree") do
      expect(page).to have_text('A child taxon')
    end
  end

  def then_i_expect_to_see_the_tagged_content
    within(".tagged-content") do
      expect(page).to have_text('tagged content')
    end
  end

  def then_i_see_a_prompt_to_delete_with_a_warning_message
    expect(page).to have_text('You are about to delete "Taxon 1"')
    expect(page).to have_text("Before you delete this taxon, make sure you've")
    expect(page).to have_link('Cancel')
    expect(page).to have_button('Delete and redirect')
  end

  def then_i_see_a_prompt_to_restore_with_an_informative_message
    expect(page).to have_text('This topic will become a draft, but the redirect will stay live until this topic is re-published.')
  end

  def and_the_tagged_content_is_tagged_to_the_parent
    expect(@patch_links_request).to have_been_made
  end

  def and_no_content_is_tagged_to_the_parent
    expect(@patch_links_request).to_not have_been_made
  end

  private

  def add_a_parent_taxon
    @parent_taxon_content_id = SecureRandom.uuid
    @parent_taxon = taxon_with_details(
      "A parent taxon",
      other_fields: { content_id: @parent_taxon_content_id }
    )
    stub_requests_for_show_page(@parent_taxon)
    #
    # Stub realistic values for links and expanded links to correctly render
    # the tree on the taxon show page
    publishing_api_has_links(
      content_id: @taxon_content_id,
      links: {
        parent_taxons: [@parent_taxon_content_id],
      }
    )
    publishing_api_has_expanded_links(
      content_id: @taxon_content_id,
      expanded_links: {
        parent_taxons: [@parent_taxon],
      }
    )
    publishing_api_has_expanded_links(
      content_id: @parent_taxon_content_id,
      expanded_links: {
        child_taxons: [@taxon]
      }
    )
  end

  def add_a_child_taxon
    @child_taxon_content_id = SecureRandom.uuid
    @child_taxon = taxon_with_details(
      "A child taxon",
      other_fields: { content_id: @child_taxon_content_id }
    )
    #
    # Stub realistic values for links and expanded links to correctly render
    # the tree on the taxon show page
    publishing_api_has_links(
      content_id: @taxon_content_id,
      links: {
        child_taxons: [@child_taxon_content_id],
      }
    )
    publishing_api_has_expanded_links(
      content_id: @taxon_content_id,
      expanded_links: {
        child_taxons: [@child_taxon],
      }
    )
    publishing_api_has_expanded_links(
      content_id: @child_taxon_content_id,
      expanded_links: {
        parent_taxons: [@taxon]
      }
    )
  end

  def add_tagged_content(fields:)
    content_item = basic_content_item("tagged content")
    publishing_api_has_linked_items(
      [content_item],
      content_id: @taxon_content_id,
      link_type: "taxons",
      fields: fields
    )

    publishing_api_has_lookups(content_item[:base_path] => content_item[:content_id])

    publishing_api_has_links(
      content_id: content_item[:content_id],
      links: {
        taxons: [@taxon_content_id],
      },
      version: 10
    )
  end

  def add_tagged_content_to_parent
    @patch_links_request = stub_publishing_api_patch_links(
      'tagged-content',
      links: { taxons: [@taxon_content_id, @parent_taxon_content_id] },
      previous_version: 10,
      bulk_publishing: true,
    )
  end
end
