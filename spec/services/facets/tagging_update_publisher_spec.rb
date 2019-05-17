require 'rails_helper'

RSpec.describe Facets::TaggingUpdatePublisher do
  let(:publishing_api) { Services.publishing_api }

  describe "save_to_publishing_api" do
    let(:facet_group_content_id) { "FACET-GROUP-CONTENT-ID" }
    let(:finder_content_id) { "FINDER-CONTENT-ID" }
    let(:pinned_item_links) { ["PINNED-ITEM-UUID"] }
    let(:finder_service_class) { Facets::FinderService }
    let(:finder_service) { double(:finder_service, pinned_item_links: pinned_item_links) }
    let(:content_item) { double(:content_item, content_id: "MY-CONTENT-ID") }
    let(:params) do
      {
        facet_groups: [facet_group_content_id],
        facet_values: ["A-FACET-VALUE-UUID"]
      }
    end

    subject(:instance) { described_class.new(content_item, params, facet_group_content_id) }

    before do
      stub_const "#{finder_service_class}::LINKED_FINDER_CONTENT_ID", finder_content_id
      allow(finder_service_class).to receive(:new).and_return(finder_service)
      allow(publishing_api).to receive(:patch_links)
    end

    context "when content is tagged to facets" do
      it "patches content item links" do
        instance.save_to_publishing_api

        expect(publishing_api).to have_received(:patch_links)
          .with(
            "MY-CONTENT-ID",
            links: {
              facet_groups: ["FACET-GROUP-CONTENT-ID"],
              facet_values: ["A-FACET-VALUE-UUID"],
              finder: [finder_content_id],
            },
            previous_version: 0,
          )
      end
    end

    context "when content isn't tagged to any facets" do
      let(:params) do
        {
          facet_groups: [],
          facet_values: [],
          promoted: true,
        }
      end

      it "doesn't patch any links if the document isn't tagged to a facet" do
        instance.save_to_publishing_api

        expect(publishing_api).to have_received(:patch_links)
          .with(
            "MY-CONTENT-ID",
            links: {
              facet_groups: [],
              facet_values: [],
              finder: [],
            },
            previous_version: 0,
          )
      end
    end

    it "returns a truthy result" do
      expect(instance.save_to_publishing_api).to be_truthy
    end

    context "without pinning the content" do
      it "does not patch finder links" do
        instance.save_to_publishing_api

        expect(publishing_api).not_to have_received(:patch_links)
          .with(finder_content_id, anything)
      end
    end

    context "pinning the content" do
      let(:params) do
        {
          facet_groups: [facet_group_content_id],
          facet_values: ["A-FACET-VALUE-UUID"],
          promoted: true,
        }
      end

      it "patches finder links" do
        instance.save_to_publishing_api

        expect(publishing_api).to have_received(:patch_links)
          .with(
            finder_content_id,
            links: {
              ordered_related_items: ["MY-CONTENT-ID", "PINNED-ITEM-UUID"],
            },
          )
      end
    end
  end
end
