require "rails_helper"

RSpec.describe "Viewing taxons" do
  include ContentItemHelper

  let(:fruits) { fake_taxon("Fruits") }
  let(:apples) { fake_taxon("Apples") }
  let(:pears) { fake_taxon("Pears") }
  let(:oranges) { fake_taxon("Oranges") }
  let(:cox) { fake_taxon("Cox") }

  scenario "Viewing a taxonomy" do
    given_a_taxonomy
    given_im_ignoring_tagged_content_for_now
    when_i_view_the_root_taxon
    then_i_see_the_entire_taxonomy
    when_i_view_the_parent
    then_i_see_the_taxonomy_from_the_parent_downwards
    and_i_can_download_the_taxonomy_in_csv_form
  end

  scenario "Viewing tagged content of a taxon" do
    given_a_taxonomy
    and_the_root_taxon_has_content_tagged_to_it
    when_i_view_the_root_taxon
    then_i_see_the_count_of_tagged_content
    then_i_see_tagged_content
  end

  scenario "Viewing associated taxons of a taxon" do
    given_a_taxonomy_with_associated_taxons
    given_im_ignoring_tagged_content_for_now
    when_i_view_the_root_taxon
    then_i_see_associated_taxons
  end

  def given_a_taxonomy
    publishing_api_has_item(fruits)
    publishing_api_has_expanded_links(
      content_id: fruits["content_id"],
      expanded_links: {
        child_taxons: [
          apples.merge(
            "links" => {
              child_taxons: [cox],
            }
          )
        ],
      }
    )

    publishing_api_has_item(apples)
    publishing_api_has_expanded_links(
      content_id: apples["content_id"],
      expanded_links: {
        parent_taxons: [fruits],
        child_taxons: [cox],
      }
    )
  end

  def given_a_taxonomy_with_associated_taxons
    publishing_api_has_item(fruits)
    publishing_api_has_expanded_links(
      content_id: fruits["content_id"],
      expanded_links: {
        child_taxons: [
          apples
        ],
      }
    )

    publishing_api_has_item(apples)
    publishing_api_has_item(pears)
    publishing_api_has_item(oranges)
    publishing_api_has_expanded_links(
      content_id: apples["content_id"],
      expanded_links: {
        parent_taxons: [fruits],
        associated_taxons: [pears, oranges],
      }
    )
  end

  def given_im_ignoring_tagged_content_for_now
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/linked/*})
      .to_return(status: 200, body: {}.to_json)
  end

  def and_the_root_taxon_has_content_tagged_to_it
    stub_request(:get, %r{publishing-api.test.gov.uk/v2/linked/apples})
      .to_return(
        body: [
          basic_content_item("Green Apples"),
          basic_content_item("Red Apples"),
        ].to_json
      )
  end

  def then_i_see_the_count_of_tagged_content
    expect(page).to have_content("Tagged content items: 2")
  end

  def then_i_see_tagged_content
    expect(page).to have_content("Green Apples")
    expect(page).to have_content("Red Apples")
  end

  def when_i_view_the_root_taxon
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/links/apples})
      .to_return(status: 200, body: {}.to_json)

    visit taxon_path(apples["content_id"])
  end

  def then_i_see_the_entire_taxonomy
    expected_titles = [
      fruits["title"],
      'Root of the taxonomy',
      apples["title"],
      cox["title"],
    ]
    rendered_titles = all(".taxon-level-title")

    rendered_titles.zip(expected_titles).each do |rendered, expected|
      within rendered do
        expect(page).to have_content expected
      end
    end
    expect(rendered_titles.count).to eq expected_titles.count
  end

  def when_i_view_the_parent
    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/links/fruits})
      .to_return(status: 200, body: {}.to_json)

    click_link fruits["title"]
  end

  def then_i_see_the_taxonomy_from_the_parent_downwards
    rendered_titles = all(".taxon-level-title")

    expect(rendered_titles.count).to eq 4
    within ".taxon-focus" do
      expect(page).to have_content("Fruits")
    end
    within ".taxon-children .taxon-depth-1" do
      expect(page).to have_content("Apples")
    end
    within ".taxon-children .taxon-depth-2" do
      expect(page).to have_content("Cox")
    end
  end

  def and_i_can_download_the_taxonomy_in_csv_form
    click_link I18n.t('views.taxons.download_csv')
    expect(page.response_headers['Content-Type']).to match(/csv/)
    expect(page.response_headers['Content-Disposition']).to match(/attachment/)
    expect(page.response_headers['Content-Disposition']).to match(/Fruits.*.csv/)
  end

  def then_i_see_associated_taxons
    expect(page).to have_content("Associated taxons")

    within(".associated-taxons") do
      expect(page).to have_content("Pears")
      expect(page).to have_content("Oranges")
    end
  end

private

  def fake_taxon(title)
    content_item_with_details(title)
  end
end
