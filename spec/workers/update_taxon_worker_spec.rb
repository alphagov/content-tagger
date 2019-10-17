require "rails_helper"

RSpec.describe UpdateTaxonWorker, "#perform" do
  include PublishingApiHelper
  include ContentItemHelper

  it "records the changes that have been made" do
    taxon = taxon_with_details(
      "Transport",
      other_fields: {
        content_id: "CONTENT-ID-TAXON",
        base_path: "/imported-topic/topic/transport",
        publication_state: "draft",
      },
    )

    publishing_api_has_item(taxon)
    publishing_api_has_expanded_links(taxon.slice(:content_id))
    stub_any_publishing_api_put_content

    expect(Version.count).to eq(0)

    UpdateTaxonWorker.new.perform(taxon["content_id"], base_path: "/transport")

    expect(Version.count).to eq(1)
    expect(Version.last).to have_attributes(
      content_id: taxon["content_id"],
      object_changes: [
        ["~", "base_path", "/imported-topic/topic/transport", "/transport"],
      ],
    )
  end

  it "makes a PUT content request to Publishing API for the Brexit taxon with 'cy' and 'en' locales" do
    brexit_taxon_content_id = "d6c2de5d-ef90-45d1-82d4-5f2438369eea"
    taxon = taxon_with_details(
      "Transport",
      other_fields: {
        content_id: brexit_taxon_content_id,
        base_path: "/imported-topic/topic/transport",
        publication_state: "draft",
      },
    )
    publishing_api_has_item(taxon)
    publishing_api_has_expanded_links(taxon.slice(:content_id))
    stub_any_publishing_api_put_content

    UpdateTaxonWorker.new.perform(brexit_taxon_content_id, base_path: "/base-path")

    assert_publishing_api_put_content(brexit_taxon_content_id, request_json_includes(locale: "en"))
    assert_publishing_api_put_content(brexit_taxon_content_id, request_json_includes(locale: "cy"))
  end
end
