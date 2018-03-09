require 'rails_helper'

RSpec.feature 'Taxon history' do
  include ContentItemHelper
  include PublishingApiHelper

  scenario 'leaving a version note when updating the taxon' do
    given_a_taxon_exists
    when_i_visit_the_taxon_edit_form
    and_i_change_the_title_and_fill_the_version_note_field
    and_i_click_save
    and_i_click_view_version_history
    then_i_will_see_the_version_history_on_the_taxon_page
  end

  def given_a_taxon_exists
    title = 'Business'

    @taxon = taxon_with_details(title, other_fields: { description: '...' })
  end

  def when_i_visit_the_taxon_edit_form
    publishing_api_has_linked_items([], content_id: @taxon['content_id'], link_type: "taxons")
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/#{@taxon['content_id']}")
      .to_return(body: @taxon.to_json)
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/links/#{@taxon['content_id']}")
      .to_return(body: { links: { parent_taxons: [] } }.to_json)
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linkables?document_type=taxon")
      .to_return(body: [{
        title: @taxon['title'],
        content_id: @taxon['content_id'],
        base_path: @taxon['base_path'],
        internal_name: @taxon['title'],
        publication_state: @taxon['publication_state']
      }].to_json)

    visit edit_taxon_path(@taxon['content_id'])
  end

  def and_i_change_the_title_and_fill_the_version_note_field
    fill_in 'taxon_title', with: 'Business tax'
    fill_in 'internal_change_note', with: 'User research shows that the title was too generic'
  end

  def and_i_click_save
    stub_request(:put, "https://publishing-api.test.gov.uk/v2/content/#{@taxon['content_id']}")
      .to_return(body: {}.to_json)
    stub_request(:patch, "https://publishing-api.test.gov.uk/v2/links/#{@taxon['content_id']}")
      .to_return(body: {}.to_json)
    stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/#{@taxon['content_id']}/publish")
      .to_return(body: {}.to_json)
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/#{@taxon['content_id']}")
      .to_return(body: { content_id: @taxon['content_id'], expanded_links: {} }.to_json)

    click_on 'Save draft'
  end

  def and_i_click_view_version_history
    click_on 'View taxon change history'
  end

  def then_i_will_see_the_version_history_on_the_taxon_page
    expect(page).to have_content '(#1)'
    expect(page).to have_content 'internal_change_note User research shows that the title was too generic'
    expect(page).to have_content 'title "Business" → "Business tax"'
  end

  def and_there_will_not_be_an_empty_associated_taxon_change
    expect(page).to_not have_content 'associated_taxons nil → [""]'
  end
end
