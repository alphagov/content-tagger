RSpec.describe Linkables do
  include ContentItemHelper
  include PublishingApiHelper

  let(:linkables) { described_class.new }

  context "when there are linkables" do
    before do
      stub_publishing_api_has_linkables(
        [
          build_linkable(
            content_id: "invalid-1",
            publication_state: "published",
            internal_name: nil,
          ),
          build_linkable(
            content_id: "invalid-2",
            publication_state: "published",
            internal_name: "",
          ),
          build_linkable(
            content_id: "valid-1",
            publication_state: "published",
            internal_name: "Valid-1!",
          ),
          build_linkable(
            content_id: "valid-2",
            publication_state: "published",
            internal_name: "Valid-2!",
          ),
        ],
        document_type: "taxon",
      )
    end

    describe ".taxons" do
      it "returns an array of hashes with only valid taxons" do
        expect(linkables.taxons).to eq(
          [%w[Valid-1! valid-1], %w[Valid-2! valid-2]],
        )
      end

      it "filters out excluded IDs" do
        expect(linkables.taxons(exclude_ids: "valid-2")).to eq(
          [%w[Valid-1! valid-1]],
        )
      end
    end

    describe ".taxons_including_root" do
      it "returns an array of hashes with only valid taxons including root" do
        expect(linkables.taxons_including_root).to eq(
          [["GOV.UK homepage", GovukTaxonomy::ROOT_CONTENT_ID], %w[Valid-1! valid-1], %w[Valid-2! valid-2]],
        )
      end

      it "filters out excluded IDs" do
        expect(linkables.taxons_including_root(exclude_ids: "valid-2")).to eq(
          [["GOV.UK homepage", GovukTaxonomy::ROOT_CONTENT_ID], %w[Valid-1! valid-1]],
        )
      end
    end
  end

  describe ".organisations" do
    it "returns an array of arrays with title and content id pairs" do
      stub_publishing_api_has_linkables(
        [
          {
            "public_updated_at" => "2014-10-15 14:35:22",
            "title" => "Student Loans Company",
            "content_id" => "9a9111aa-1db8-4025-8dd2-e08ec3175e72",
            "publication_state" => "published",
            "base_path" => "/government/organisations/student-loans-company",
            "internal_name" => "Student Loans Company",
          },
        ],
        document_type: "organisation",
      )

      expect(linkables.organisations).to eq [["Student Loans Company", "9a9111aa-1db8-4025-8dd2-e08ec3175e72"]]
    end
  end
end
