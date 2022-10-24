RSpec.feature "Taxon Search" do
  include PublishingApiHelper
  include ContentItemHelper

  scenario "User navigates using pagination links" do
    given_there_are_multiple_pages_of_taxons
    when_i_visit_the_taxonomy_page
    then_i_can_see_the_first_page_of_taxons
    and_i_can_see_pagination_links
    when_i_visit_the_next_page
    then_i_can_see_the_second_page_of_taxons
  end

  scenario "User searches for taxons" do
    given_there_are_taxons_for_search
    when_i_visit_the_taxonomy_page
    then_i_can_see_all_the_taxons
    when_i_search_for_taxons
    then_i_can_see_my_search_results
  end

  def given_there_are_multiple_pages_of_taxons
    @taxon1 = content_item_with_details(
      "I Am A Taxon 1",
      other_fields: {
        content_id: "ID-1",
        base_path: "/foo",
        publication_state: "published",
      },
    )
    @taxon2 = content_item_with_details(
      "I Am Another Taxon 2",
      other_fields: {
        content_id: "ID-2",
        base_path: "/bar",
        publication_state: "published",
      },
    )
    @taxon3 = content_item_with_details(
      "I Am Yet Another Taxon 3",
      other_fields: {
        content_id: "ID-3",
        base_path: "/bar",
        publication_state: "published",
      },
    )

    publishing_api_has_taxons(
      [@taxon1, @taxon2, @taxon3],
      page: 1,
      per_page: 2,
    )
    publishing_api_has_taxons(
      [@taxon1, @taxon2, @taxon3],
      page: 2,
      per_page: 2,
    )
  end

  def given_there_are_taxons_for_search
    @taxon1 = content_item_with_details(
      "Taxon 1",
      other_fields: {
        content_id: "ID-1",
        base_path: "/foo",
        publication_state: "published",
      },
    )
    @taxon2 = content_item_with_details(
      "Taxon 2",
      other_fields: {
        content_id: "ID-2",
        base_path: "/bar",
        publication_state: "published",
      },
    )

    publishing_api_has_taxons(
      [@taxon1, @taxon2],
      document_type: "taxon",
      page: 1,
      per_page: 2,
    )

    publishing_api_has_taxons(
      [@taxon2],
      document_type: "taxon",
      page: 1,
      per_page: 50,
      q: "Taxon 2",
    )
  end

  def when_i_visit_the_taxonomy_page
    visit taxons_path(per_page: 2)
  end

  def then_i_can_see_the_first_page_of_taxons
    expect(page).to have_text(@taxon1[:title])
    expect(page).to have_text(@taxon2[:title])

    expect(page).to_not have_text(@taxon3[:title])
  end

  def and_i_can_see_pagination_links
    pagination_list = find(".pagination")
    page_links = pagination_list.all("li.page").map(&:text)

    # We can see 2 pages
    expect(page_links).to include("1")
    expect(page_links).to include("2")

    # There is no 3rd page
    expect(page_links).to_not include("3")

    # We start on the first page
    expect(find("li.page.active").text).to eq("1")

    # We also have Next and Last links
    expect(pagination_list).to have_selector("li.next_page", text: /next/i)
    expect(pagination_list).to have_selector("li.last", text: /last/i)
  end

  def when_i_visit_the_next_page
    pagination_list = find(".pagination")

    within pagination_list do
      click_link "Next"
    end
  end

  def then_i_can_see_the_second_page_of_taxons
    expect(page).to have_text(@taxon3[:title])

    expect(page).to_not have_text(@taxon1[:title])
    expect(page).to_not have_text(@taxon2[:title])
  end

  def then_i_can_see_all_the_taxons
    expect(page).to have_text(@taxon1[:title])
    expect(page).to have_text(@taxon2[:title])
  end

  def when_i_search_for_taxons
    find("#taxon_search_query").set("Taxon 2")
    click_button "Search"
  end

  def then_i_can_see_my_search_results
    expect(page).to have_text(@taxon2[:title])

    expect(page).to_not have_text(@taxon1[:title])
  end
end
