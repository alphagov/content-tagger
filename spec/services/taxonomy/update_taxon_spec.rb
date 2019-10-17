require "rails_helper"

RSpec.describe Taxonomy::UpdateTaxon do
  include ContentItemHelper

  before do
    @taxon = Taxon.new(
      title: "A Title",
      document_type: "taxon",
      description: "Description",
      base_path: "/level-one/slug",
      parent_content_id: "CONTENT-ID-PARENT",
      associated_taxons: %w[1234],
    )
    allow(Taxonomy::SaveTaxonVersion).to receive(:call)

    parent_taxon = taxon_with_details(
      "root", other_fields: { base_path: "/level-one", content_id: "CONTENT-ID-PARENT" }
    )
    publishing_api_has_item(parent_taxon)
    publishing_api_has_expanded_links(content_id: "CONTENT-ID-PARENT")
  end
  let(:publish) { described_class.call(taxon: @taxon) }

  describe ".call" do
    context "with a valid taxon form" do
      it "publishes the document via the publishing API" do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links

        publish

        assert_publishing_api_put_content(@taxon.content_id)
        assert_publishing_api_patch_links(@taxon.content_id, links: {
                                            root_taxon: [],
                                            parent_taxons: %w[CONTENT-ID-PARENT],
                                            associated_taxons: %w[1234],
                                            legacy_taxons: [],
                                          })
      end
    end

    context "when the taxon has no parent" do
      before { @taxon.parent_content_id = "" }

      it "patches the links hash with an empty array" do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links

        publish
        assert_publishing_api_patch_links(@taxon.content_id, links: {
                                            root_taxon: [],
                                            parent_taxons: [],
                                            associated_taxons: %w[1234],
                                            legacy_taxons: [],
                                          })
      end
    end

    context "when the taxon has no associated taxons" do
      before { @taxon.associated_taxons = [] }

      it "patches the links hash with an empty array" do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links

        publish
        assert_publishing_api_patch_links(@taxon.content_id, links: {
                                            root_taxon: [],
                                            parent_taxons: %w[CONTENT-ID-PARENT],
                                            associated_taxons: [],
                                            legacy_taxons: [],
                                          })
      end
    end

    context "when the taxon has nil for associated taxons" do
      before { @taxon.associated_taxons = nil }

      it "patches the links hash with an empty array" do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links

        publish
        assert_publishing_api_patch_links(@taxon.content_id, links: {
                                            root_taxon: [],
                                            parent_taxons: %w[CONTENT-ID-PARENT],
                                            associated_taxons: [],
                                            legacy_taxons: [],
                                          })
      end
    end

    context "with an unprocessable entity error from the API" do
      let(:error) do
        GdsApi::HTTPUnprocessableEntity.new(
          422,
          "An internal error message",
          "error" => { "message" => "Some backend error" },
        )
      end

      before do
        allow(Services.publishing_api).to receive(:put_content).and_raise(error)
      end

      it "raises an error with a generic message and notifies GovukError if it is not a base path conflict" do
        publishing_api_has_lookups("")
        expect(GovukError).to receive(:notify).with(error)
        expect { publish }.to raise_error(
          Taxonomy::UpdateTaxon::InvalidTaxonError,
          /there was a problem with your request/i,
        )
      end

      it "raises an error with a specific message if it is a base path conflict" do
        publishing_api_has_lookups(SecureRandom.uuid)
        allow(Services.publishing_api).to receive(:lookup_content_id).and_return(SecureRandom.uuid)
        expect { publish }.to raise_error(
          Taxonomy::UpdateTaxon::InvalidTaxonError,
          /<a href="(.+)">taxon<\/a> with this slug already exists/,
        )
      end
    end

    context "with the Brexit taxon" do
      it "publishes the document in the 'en' and 'cy' locale via the Publishing API" do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links

        @taxon.content_id = "d6c2de5d-ef90-45d1-82d4-5f2438369eea"

        described_class.call(taxon: @taxon)

        assert_publishing_api_put_content(@taxon.content_id, request_json_includes(locale: "en"))
        assert_publishing_api_put_content(@taxon.content_id, request_json_includes(locale: "cy"))
      end
    end
  end
end
