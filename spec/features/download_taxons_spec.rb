require "rails_helper"

RSpec.feature "Download taggings", type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario "downloading tagged content" do
    given_a_taxon_exists
    when_i_visit_the_taxons_page
    when_i_click_the_download_button
    then_i_should_receive_a_csv_with_taxons
  end

  def given_a_taxon_exists
    content_id = "dfd51e0c-ce3f-4cb5-8c0d-4a726e54ba1e"

    taxon = content_item_with_details(
      "My Taxon",
      other_fields: { content_id:, description: "Foo" },
    )

    stub_requests_for_show_page(taxon)

    stub_request(:get, %r{https://publishing-api.test.gov.uk/v2/content*})
      .to_return(body: { results: [taxon], total: 1, pages: 1, current_page: 1 }.to_json)
  end

  def when_i_visit_the_taxons_page
    visit taxons_path
  end

  def when_i_click_the_download_button
    click_link "Download published taxons as CSV"
  end

  def then_i_should_receive_a_csv_with_taxons
    expect(page.body).to eql("title,description,content_id,base_path
My Taxon,Foo,dfd51e0c-ce3f-4cb5-8c0d-4a726e54ba1e,/level-one/my-taxon
")
  end
end
