require "rails_helper"

RSpec.feature "Delete Taxon", type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario "deleting a taxon with no children or tagged content" do
    given_a_taxon_with_no_children
    when_i_visit_the_taxon_page
    when_i_click_delete_taxon
    then_i_see_a_basic_prompt_to_delete
    when_i_confirm_deletion
    then_the_taxon_is_deleted
  end

  scenario "deleting a taxon with children" do
    given_a_taxon_with_children
    when_i_visit_the_taxon_page
    then_i_expect_to_see_the_child_taxon
    when_i_click_delete_taxon
    then_i_see_a_prompt_to_delete_with_a_warning_message
    when_i_confirm_deletion
    then_the_taxon_is_deleted
  end

  scenario "deleting a taxon with tagged content" do
    given_a_taxon_with_tagged_content
    when_i_visit_the_taxon_page
    then_i_expect_to_see_the_tagged_content
    when_i_click_delete_taxon
    then_i_see_a_prompt_to_delete_with_a_warning_message
    when_i_confirm_deletion
    then_the_taxon_is_deleted
  end

  scenario "restoring a deleted taxon" do
    given_a_deleted_taxon
    when_i_visit_the_taxon_page

    when_i_click_restore_taxon
    then_the_taxon_is_restored
  end

  def given_a_taxon_with_no_children
    @taxon_content_id = SecureRandom.uuid
    @taxon = content_item_with_details(
      "Taxon 1",
      other_fields: { content_id: @taxon_content_id }
    )
    publishing_api_has_item(@taxon)

    publishing_api_has_links(
      content_id: @taxon_content_id,
      links: {}
    )
    publishing_api_has_expanded_links(
      content_id: @taxon_content_id,
      expanded_links: {}
    )
    publishing_api_has_linked_items(
      [],
      content_id: @taxon_content_id,
      link_type: "taxons"
    )
  end

  def given_a_taxon_with_children
    given_a_taxon_with_no_children
    add_a_child_taxon
  end

  def given_a_taxon_with_tagged_content
    given_a_taxon_with_no_children
    add_tagged_content
  end

  def given_a_deleted_taxon
    @taxon_content_id = SecureRandom.uuid
    @taxon = content_item_with_details(
      "Taxon 2",
      other_fields: {
        base_path: "/education/taxon-2",
        content_id: @taxon_content_id,
        description: 'A description of Taxon 2.'
      },
      unpublished: true
    )
    list_taxons
    publishing_api_has_item(@taxon)
    publishing_api_has_links(
      content_id: @taxon_content_id,
      links: {}
    )

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/#{@taxon_content_id}")
      .to_return(status: 200, body: { expanded_links: {} }.to_json)
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linked/#{@taxon_content_id}?fields%5B%5D=base_path&fields%5B%5D=content_id&fields%5B%5D=document_type&fields%5B%5D=title&link_type=taxons")
      .to_return(status: 200, body: {}.to_json)
  end

  def when_i_visit_the_taxon_page
    visit taxon_path(@taxon_content_id)
  end

  def when_i_click_delete_taxon
    click_on "Delete taxon"
  end

  def when_i_click_restore_taxon
    @put_content_request = stub_publishing_api_put_content(@taxon_content_id, {})
    @patch_links_request = stub_publishing_api_patch_links(@taxon_content_id, {})
    @publish_request = stub_publishing_api_publish(@taxon_content_id, update_type: 'minor')
    click_link "Restore taxon"
  end

  def then_i_see_a_basic_prompt_to_delete
    expect(page).to have_text('You are about to delete "internal name for Taxon 1"')
    expect(page).to_not have_text("Before you delete this taxon, make sure you've")
    expect(page).to have_link('Cancel')
    expect(page).to have_link('Delete')
  end

  def when_i_confirm_deletion
    @unpublish_request = stub_publishing_api_unpublish(@taxon_content_id, body: { type: :gone }.to_json)
    publishing_api_has_taxons([])
    click_on "Delete"
  end

  def then_the_taxon_is_deleted
    expect(@unpublish_request).to have_been_made
  end

  def then_the_taxon_is_restored
    expect(@put_content_request).to have_been_made
    expect(@patch_links_request).to have_been_made
    expect(@publish_request).to have_been_made
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
    expect(page).to have_text('You are about to delete "internal name for Taxon 1"')
    expect(page).to have_text("Before you delete this taxon, make sure you've")
    expect(page).to have_link('Cancel')
    expect(page).to have_link('Delete')
  end

private

  def add_a_child_taxon
    @child_taxon_content_id = SecureRandom.uuid
    @child_taxon = content_item_with_details(
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

  def add_tagged_content
    publishing_api_has_linked_items(
      [basic_content_item("tagged content")],
      content_id: @taxon_content_id,
      link_type: "taxons"
    )
  end

  def list_taxons
    publishing_api_has_content(
      [@taxon],
      document_type: 'taxon',
      order: '-public_updated_at',
      page: 1,
      per_page: 50,
      q: '',
      states: ['published']
    )
    publishing_api_has_content(
      [@taxon],
      document_type: 'taxon',
      order: '-public_updated_at',
      page: 1,
      per_page: 50,
      q: '',
      states: ['unpublished']
    )
  end
end
