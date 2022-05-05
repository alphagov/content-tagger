require "rails_helper"

RSpec.describe Linkables do
  include ContentItemHelper
  include PublishingApiHelper

  before(:each) do
    stub_the_publishing_content
  end

  let(:linkables) { Linkables.new }

  context "there are linkables" do
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

  describe ".topics" do
    it "returns an array of hashes with title and content id pairs" do
      stub_publishing_api_has_linkables(
        [
          {
            "public_updated_at" => "2016-04-07 10:34:05",
            "title" => "Pension scheme administration",
            "content_id" => "e1d6b771-a692-4812-a4e7-7562214286ef",
            "publication_state" => "published",
            "base_path" => "/topic/business-tax/pension-scheme-administration",
            "internal_name" => "Business tax / Pension scheme administration",
          },
          {
            "public_updated_at" => "2016-04-07 10:34:05",
            "title" => nil,
            "content_id" => "3535b8ad-7209-4c97-9dac-e25c25d9c27c",
            "publication_state" => "published",
            "base_path" => "/topic/redirect",
            "internal_name" => nil,
          },
          {
            "base_path" => "/topic/employing-people-mainstream-copy/contracts-mainstream-copy",
            "internal_name" => "Employing People / Contracts",
            "publication_state" => "published",
            "content_id" => "CONTENT-ID-EMPLOYING-COPY",
          },
        ],
        document_type: "topic",
      )

      stub_the_publishing_content

      expected = {
        "Business tax" => [
          ["Business tax / Pension scheme administration", "e1d6b771-a692-4812-a4e7-7562214286ef"],
        ],
      }

      expect(linkables.topics).to eq expected
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

  def stub_the_publishing_content
    stub_publishing_api_has_content(
      [
        {
          "public_updated_at" => "2016-04-07 10:34:05",
          "title" => "Pension scheme administration",
          "content_id" => "e1d6b771-a692-4812-a4e7-7562214286ef",
          "publication_state" => "published",
          "base_path" => "/topic/business-tax/pension-scheme-administration",
          "internal_name" => "Business tax / Pension scheme administration",
        },
        {
          "public_updated_at" => "2016-04-07 10:34:05",
          "title" => nil,
          "content_id" => "3535b8ad-7209-4c97-9dac-e25c25d9c27c",
          "publication_state" => "published",
          "base_path" => "/topic/redirect",
          "internal_name" => nil,
        },
        {
          "base_path" => "/topic/employing-people-mainstream-copy/contracts-mainstream-copy",
          "internal_name" => "Employing People / Contracts",
          "publication_state" => "published",
          "content_id" => "CONTENT-ID-EMPLOYING-COPY",
          "details" => {
            "mainstream_browse_origin" => "notnil",
          },
        },
        {
          "base_path" => "/topic/disabilities-mainstream-copy/benefits-mainstream-copy",
          "internal_name" => "Disabilities / Benefits",
          "publication_state" => "draft",
          "content_id" => "CCONTENT-ID-BENEFIT-COPY",
          "details" => {
            "mainstream_browse_origin" => "",
          },
        },
      ],
      document_type: "topic",
      per_page: 10_000,
      fields: %w[content_id details],
    )
  end
end
