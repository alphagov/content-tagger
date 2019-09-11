require 'rails_helper'

RSpec.describe Facets::TaggingUpdatePublisher do
  let(:publishing_api) { Services.publishing_api }

  describe "save_to_publishing_api" do
    let(:facet_group_content_id) { "FACET-GROUP-CONTENT-ID" }
    let(:finder_content_id) { "FINDER-CONTENT-ID" }
    let(:finder_service_class) { Facets::FinderService }
    let(:finder_service) { double(:finder_service) }
    let(:links) { { "ordered_related_items": %w[RELATED-LINK] } }
    let(:content_item) { double(:content_item, content_id: "MY-CONTENT-ID", links: links) }
    let(:links_item) { { content_id: "MY-CONTENT-ID", links: links } }
    let(:params) do
      {
        facet_groups: [facet_group_content_id],
        facet_values: %w[A-FACET-VALUE-UUID]
      }
    end

    subject(:instance) { described_class.new(content_item, params, facet_group_content_id) }

    before do
      stub_const "#{finder_service_class}::LINKED_FINDER_CONTENT_ID", finder_content_id
      stub_publishing_api_has_links(links_item)
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
              facet_groups: %w[FACET-GROUP-CONTENT-ID],
              facet_values: %w[A-FACET-VALUE-UUID],
              finder: [finder_content_id],
              ordered_related_items: [finder_content_id, "RELATED-LINK"],
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
          ordered_related_items: %w[RELATED-LINK],
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
              ordered_related_items: %w[RELATED-LINK],
            },
            previous_version: 0,
          )
      end
    end

    it "returns a truthy result" do
      expect(instance.save_to_publishing_api).to be_truthy
    end
  end
end
