require 'rails_helper'

RSpec.feature 'Bulk publishing', type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario 'A single taxon' do
    given_the_publishing_api_has_a_single_taxon
    when_i_visit_the_show_taxon_page
    then_i_can_see_the_publish_tree_button
    when_i_click_the_publish_tree_button
    then_i_see_the_confirmation_page
    when_i_click_confirm_publish
    then_i_see_the_confirmation_message
  end

  def given_the_publishing_api_has_a_single_taxon
    taxon = taxon_with_details(
      'Foo',
      other_fields: {
        content_id: 'single-taxon-content-id',
        publication_state: 'draft'
      }
    )
    stub_requests_for_show_page(taxon)
  end

  def when_i_visit_the_show_taxon_page
    visit taxon_path('single-taxon-content-id')
  end

  def then_i_can_see_the_publish_tree_button
    expect(page).to have_link 'Publish tree'
  end

  def when_i_click_the_publish_tree_button
    click_link 'Publish tree'
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_text 'You are about to publish this topic and its children'
  end

  def when_i_click_confirm_publish
    click_button 'Confirm publish'
  end

  def then_i_see_the_confirmation_message
    expect(page).to have_text 'The taxons will be published shortly'
  end
end
