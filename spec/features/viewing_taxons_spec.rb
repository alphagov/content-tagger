require "rails_helper"

RSpec.describe "Viewing taxons" do
  include ContentItemHelper

  let(:food)   { fake_taxon("Food") }
  let(:fruits) { fake_taxon("Fruits") }
  let(:apples) { fake_taxon("Apples") }
  let(:round_things) { fake_taxon("Round things") }

  before do
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/links/*})
      .to_return(status: 200, body: {}.to_json)

    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/linked/*})
      .to_return(status: 200, body: {}.to_json)
  end

  scenario "Viewing a taxonomy" do
    given_a_taxonomy
    when_i_view_the_top_level_taxon
    then_i_see_the_entire_taxonomy
    when_i_view_one_of_the_children
    then_i_see_the_taxonomy_from_the_child_downwards
    and_i_can_download_the_taxonomy_in_csv_form
  end

  scenario "Navigating multiple parents" do
    given_a_taxonomy
    and_a_taxon_with_multiple_parents
    when_i_view_the_top_level_taxon
    then_i_can_see_the_multi_parent_taxon
    and_can_navigate_to_the_other_parent
  end

  scenario "Viewing tagged content of a taxon" do
    given_a_taxonomy
    and_the_top_level_taxon_has_content_tagged_to_it
    when_i_view_the_top_level_taxon
    then_i_see_tagged_content
  end

  def and_the_top_level_taxon_has_content_tagged_to_it
    stub_request(:get, %r{publishing-api.test.gov.uk/v2/linked/food-id})
      .to_return(
        body: [basic_content_item("Tagged content")].to_json
      )
  end

  def then_i_see_tagged_content
    expect(page).to have_content("Tagged content")
  end

  def fake_taxon(title)
    { "title" => title, "content_id" => "#{title.parameterize}-id", "details" => {} }
  end

  def given_a_taxonomy
    publishing_api_has_item(food)
    publishing_api_has_item(fruits)

    publishing_api_has_expanded_links(
      content_id: food["content_id"],
      expanded_links: { child_taxons: [fruits] },
    )
    publishing_api_has_expanded_links(
      content_id: fruits["content_id"],
      expanded_links: {
        parent_taxons: [food],
        child_taxons: [apples]
      },
    )
    publishing_api_has_expanded_links(
      content_id: apples["content_id"],
      expanded_links: { parent_taxons: [fruits] },
    )
  end

  def and_a_taxon_with_multiple_parents
    publishing_api_has_expanded_links(
      content_id: apples["content_id"],
      expanded_links: { parent_taxons: [fruits, round_things] },
    )
    publishing_api_has_item(round_things)
    publishing_api_has_expanded_links(
      content_id: round_things["content_id"],
      expanded_links: { child_taxons: [apples] },
    )
  end

  def when_i_view_the_top_level_taxon
    visit taxon_path(food["content_id"])
  end

  def then_i_see_the_entire_taxonomy
    expected_titles = [
      food["title"],
      fruits["title"],
      apples["title"],
    ]
    rendered_titles = all(".taxon-level-title")

    expect(rendered_titles.count).to eq 3
    rendered_titles.zip(expected_titles).each do |rendered, expected|
      within rendered do
        expect(page).to have_content expected
      end
    end
  end

  def when_i_view_one_of_the_children
    within ".taxon-depth-1" do
      click_link fruits["title"]
    end
  end

  def then_i_see_the_taxonomy_from_the_child_downwards
    rendered_titles = all(".taxon-level-title")

    expect(rendered_titles.count).to eq 2
    expect(rendered_titles.first).to have_content fruits["title"]
  end

  def then_i_can_see_the_multi_parent_taxon
    rendered_taxons = all(".taxon-level")

    within rendered_taxons.last do
      within ".taxon-level-parent-links" do
        expect(page).to have_content("Round things")
        expect(page).to have_content("Fruits")
      end
    end
  end

  def and_can_navigate_to_the_other_parent
    rendered_taxons = all(".taxon-level")
    within rendered_taxons.last do
      click_link "Round things"
    end

    rendered_titles = all(".taxon-level-title")
    within rendered_titles.first do
      expect(page).to have_content round_things["title"]
    end
  end

  def and_i_can_download_the_taxonomy_in_csv_form
    click_link I18n.t('views.taxons.download_csv')
    expect(page.response_headers['Content-Type']).to match(/csv/)
    expect(page.response_headers['Content-Disposition']).to match(/attachment/)
    expect(page.response_headers['Content-Disposition']).to match(/Fruits.*.csv/)
  end
end
