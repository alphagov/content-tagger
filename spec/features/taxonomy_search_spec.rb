require "rails_helper"

RSpec.feature "Taxonomy Search" do
  include PublishingApiHelper

  scenario "User navigates using pagination links" do
    given_there_are_multiple_pages_of_taxons
    when_i_visit_the_taxonomy_page
    then_i_can_see_the_first_page_of_taxons
    and_i_can_see_pagination_links
    when_i_visit_the_next_page
    then_i_can_see_the_second_page_of_taxons
  end

  def given_there_are_multiple_pages_of_taxons
    @taxon_1 = {
      title: "I Am A Taxon 1",
      content_id: "ID-1",
      base_path: "/foo",
      internal_name: "I Am A Taxon 1",
      publication_state: 'active'
    }
    @taxon_2 = {
      title: "I Am Another Taxon 2",
      content_id: "ID-2",
      base_path: "/bar",
      internal_name: "I Am Another Taxon 2",
      publication_state: 'active'
    }
    @taxon_3 = {
      title: "I Am Yet Another Taxon 3",
      content_id: "ID-3",
      base_path: "/bar",
      internal_name: "I Am Yet Another Taxon 3",
      publication_state: 'active'
    }

    publishing_api_has_taxons(
      [@taxon_1, @taxon_2, @taxon_3],
      page: 1,
      per_page: 2
    )
    publishing_api_has_taxons(
      [@taxon_1, @taxon_2, @taxon_3],
      page: 2,
      per_page: 2
    )
  end

  def when_i_visit_the_taxonomy_page
    visit taxons_path(per_page: 2)
  end

  def then_i_can_see_the_first_page_of_taxons
    expect(page).to have_text(@taxon_1[:title])
    expect(page).to have_text(@taxon_2[:title])

    expect(page).to_not have_text(@taxon_3[:title])
  end

  def and_i_can_see_pagination_links
    pagination_list = find('.pagination')
    page_links = pagination_list.all('li.page').map(&:text)

    # We can see 2 pages
    expect(page_links).to include('1')
    expect(page_links).to include('2')

    # There is no 3rd page
    expect(page_links).to_not include('3')

    # We start on the first page
    expect(find('li.page.active').text).to eq('1')

    # We also have Next and Last links
    expect(pagination_list).to have_selector('li.next_page', text: /next/i)
    expect(pagination_list).to have_selector('li.last', text: /last/i)
  end

  def when_i_visit_the_next_page
    pagination_list = find('.pagination')

    within pagination_list do
      click_link 'Next'
    end
  end

  def then_i_can_see_the_second_page_of_taxons
    expect(page).to have_text(@taxon_3[:title])

    expect(page).to_not have_text(@taxon_1[:title])
    expect(page).to_not have_text(@taxon_2[:title])
  end
end
