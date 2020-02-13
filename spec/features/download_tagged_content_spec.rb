require "rails_helper"

RSpec.feature "Download taggings", type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario "downloading tagged content" do
    given_a_taxon_with_tagged_content
    when_i_visit_the_taxon_tagged_content_page
    when_i_click_the_download_button
    then_i_should_receive_a_csv_with_tagged_content
  end

  def given_a_taxon_with_tagged_content
    @content_id = SecureRandom.uuid

    taxon = taxon_with_details(
      "Taxon 1",
      other_fields: { content_id: @content_id },
    )

    stub_requests_for_show_page(taxon)
  end

  def when_i_visit_the_taxon_tagged_content_page
    visit taxon_tagged_content_path(@content_id)
  end

  def when_i_click_the_download_button
    content_item = basic_content_item(
      "tagged-content",
      other_fields: {
        first_published_at: "2012-01-26T13:10:47Z",
        public_updated_at: "2012-10-12T15:54:21Z",
      },
    )

    stub_publishing_api_has_linked_items(
      [content_item],
      content_id: @content_id,
      link_type: "taxons",
      fields: Taxonomy::TaxonomyExport::COLUMNS,
    )

    publishing_api_has_links_for_content_ids(
      "tagged-content" =>
       {
         "links" => {
           "primary_publishing_organisation" => %w[org-content-id],
         },
       },
    )

    stub_publishing_api_has_content(
      [{ "content_id" => "org-content-id", "title" => "org title" }],
      document_type: "organisation",
      fields: %w[content_id title],
      page: 1,
      per_page: 600,
    )

    click_link "Download as CSV"
  end

  def then_i_should_receive_a_csv_with_tagged_content
    expect(page.body).to eql <<~DOC
      title,description,content_id,base_path,document_type,first_published_at,public_updated_at,primary_publishing_organisation
      tagged-content,,tagged-content,/level-one/tagged-content,guidance,2012-01-26T13:10:47Z,2012-10-12T15:54:21Z,org title
    DOC
  end
end
