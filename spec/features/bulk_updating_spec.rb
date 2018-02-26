require 'rails_helper'

RSpec.feature 'Bulk updating', type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario 'Update the phase of decedent taxons' do
    given_a_published_taxon_with_draft_children
    when_i_visit_the_show_taxon_page
    then_i_can_see_the_bulk_update_button
    when_i_click_the_bulk_update_button
    then_i_see_the_confirmation_page
    when_i_click_confirm_update
    then_i_see_the_confirmation_message
  end

  def given_a_published_taxon_with_draft_children
    @parent_content_id = 'PARENT-TAXON-CONTENT-ID'
    @child_content_id = 'CHILD-TAXON-CONTENT-ID'

    @parent_taxon = taxon_with_details(
      'Parent taxon',
      other_fields: {
        content_id: @parent_content_id,
        phase: 'beta',
        publication_state: 'published',
      }
    )

    @child_taxon = taxon_with_details(
      "Child taxon",
      other_fields: {
        content_id: @child_content_id,
        phase: 'alpha',
        publication_state: 'draft',
      }
    )

    stub_requests_for_show_page(@parent_taxon)

    publishing_api_has_links(
      content_id: @parent_content_id,
      links: {
        child_taxons: [@child_content_id],
      }
    )

    publishing_api_has_expanded_links(
      content_id: @parent_content_id,
      expanded_links: {
        child_taxons: [@child_taxon],
      }
    )

    publishing_api_has_expanded_links(
      content_id: @child_content_id,
      expanded_links: {
        parent_taxons: [@parent_taxon]
      }
    )
  end

  def when_i_visit_the_show_taxon_page
    visit taxon_path(@parent_content_id)
  end

  def then_i_can_see_the_bulk_update_button
    expect(page).to have_link 'Change phase for this taxon and its children'
  end

  def when_i_click_the_bulk_update_button
    click_link 'Change phase for this taxon and its children'
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_text 'You are about to update the phase of this taxon and its children to'
    expect(page).to have_select('taxon_phase', selected: 'beta')
  end

  def when_i_click_confirm_update
    Sidekiq::Testing.inline!

    # We need to make a get request for each item to determine whether the taxon
    # is published or not
    publishing_api_has_item(@parent_taxon)
    publishing_api_has_item(@child_taxon)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish

    click_button 'Confirm bulk update'

    assert_publishing_api_put_content(
      @parent_content_id,
      request_json_includes(phase: 'beta')
    )

    # When updating a published taxon, a new draft edition is created. We need
    # to publish this newly created draft edition so that the updates are
    # reflected in the published state.
    assert_publishing_api_publish(@parent_content_id)

    assert_publishing_api_put_content(
      @child_content_id,
      request_json_includes(phase: 'beta')
    )
  end

  def then_i_see_the_confirmation_message
    expect(page).to have_text 'The taxons will be updated shortly'
  end
end
