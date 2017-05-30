require "rails_helper"

RSpec.feature "Download taggings", type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario "downloading tagged content" do
    given_a_taxon_with_tagged_content
    when_i_visit_the_taxon_page
    when_i_click_the_download_button
    then_i_should_receive_a_csv_with_tagged_content
  end

  def given_a_taxon_with_tagged_content
    @content_id = SecureRandom.uuid

    taxon = content_item_with_details(
      "Taxon 1",
      other_fields: { content_id: @content_id }
    )

    publishing_api_has_item(taxon)
    publishing_api_has_links(content_id: @content_id, links: {})
    publishing_api_has_expanded_links(content_id: @content_id, expanded_links: {})

    # for the show page
    publishing_api_has_linked_items(
      [basic_content_item("tagged content")],
      content_id: @content_id,
      link_type: "taxons",
    )

    # for the tagged item download
    publishing_api_has_linked_items(
      [basic_content_item("tagged content")],
      content_id: @content_id,
      link_type: "taxons",
      fields: Taxonomy::TaxonomyExport::COLUMNS,
    )
  end

  def when_i_visit_the_taxon_page
    visit taxon_path(@content_id)
  end

  def when_i_click_the_download_button
    click_link "Download as CSV"
  end

  def then_i_should_receive_a_csv_with_tagged_content
    expect(page.body).to eql(<<~doc
      title,description,content_id,base_path,document_type
      tagged content,,tagged-content,/path/tagged-content,guidance
    doc
    )
  end
end
