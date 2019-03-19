require 'rails_helper'

RSpec.feature 'View a facet group', type: :feature do
  include PublishingApiHelper

  scenario 'Viewing a published facet group' do
    given_there_is_a_published_facet_group
    when_i_view_the_facet_group
    i_can_see_facets_and_facet_values_for_the_facet_group
  end

  def given_there_is_a_published_facet_group
    stub_facet_groups_lookup
    stub_facet_group_lookup

    visit facets_facet_groups_path
  end

  def when_i_view_the_facet_group
    click_link 'Example facet group'
  end

  def i_can_see_facets_and_facet_values_for_the_facet_group
    expect(page).to have_content("Example facet")
    expect(page).to have_content("Agriculture")
    expect(page).to have_content("Aerospace")
  end
end
