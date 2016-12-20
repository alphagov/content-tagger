require "rails_helper"

RSpec.describe "Copying taxons for use in a spreadsheet" do
  include ContentItemHelper

  scenario "Copy taxons" do
    given_there_are_taxons
    when_i_visit_the_bulk_tag_by_upload_page
    and_i_click_to_copy_taxons
    then_i_can_see_a_table_with_taxons_to_copy
  end

  def given_there_are_taxons
    @taxon_1 = basic_content_item(
      "I Am A Taxon",
      other_fields: {
        content_id: "ID-1",
        base_path: "/foo",
        publication_state: 'active'
      }
    )
    @taxon_2 = basic_content_item(
      "I Am Another Taxon",
      other_fields: {
        content_id: "ID-2",
        base_path: "/bar",
        publication_state: 'active'
      }
    )

    publishing_api_has_linkables([@taxon_1, @taxon_2], document_type: 'taxon')

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/links/ID-1")
      .to_return(body: { links: { parent_taxons: [] } }.to_json)

    empty_details = { "details" => {} }

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-1")
      .to_return(body: @taxon_1.merge(empty_details).to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-2")
      .to_return(body: @taxon_2.merge(empty_details).to_json)
  end

  def when_i_visit_the_bulk_tag_by_upload_page
    visit tagging_spreadsheets_path
  end

  def and_i_click_to_copy_taxons
    find_link(I18n.t('tag_import.view_taxons')).click
  end

  def then_i_can_see_a_table_with_taxons_to_copy
    table = find('table')
    table_head = table.all('thead th').map(&:text)
    table_body = table.find('tbody').text

    expect(table_head).to include(/title/i)
    expect(table_head).to include(/content id/i)
    expect(table_head).to include(/link type/i)

    expect(table_body).to include(@taxon_1[:content_id])
    expect(table_body).to include(@taxon_1[:title])

    expect(table_body).to include(@taxon_2[:content_id])
    expect(table_body).to include(@taxon_2[:title])
    expect(table_body).to include('taxons')
  end
end
