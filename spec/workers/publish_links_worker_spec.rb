require "rails_helper"

RSpec.describe PublishLinksWorker do
  describe "#perform" do
    before do
      publishing_api_has_lookups("/content-1" => "content-1-ID", "/content-2" => "content-2-ID")
      allow(TagMapping).to receive(:update_publish_completed_at)
    end

    def publish_content_1_links!
      PublishLinksWorker.new.perform(
        "/content-1",
        "tag_mapping_ids" => [333],
        "organisations" => ["gds-ID"]
      )
    end

    def publish_content_2_links!
      PublishLinksWorker.new.perform(
        "/content-2",
        "tag_mapping_ids" => [444, 555],
        "taxons" => ["some-taxon-ID", "another-taxon-ID"]
      )
    end

    it "sends the links payload to the publishing API" do
      expect(Services.publishing_api).to receive(:patch_links).with(
        "content-1-ID",
        links: { "organisations" => ["gds-ID"] }
      )
      expect(Services.publishing_api).to receive(:patch_links).with(
        "content-2-ID",
        links: { "taxons" => ["some-taxon-ID", "another-taxon-ID"] }
      )

      publish_content_1_links!
      publish_content_2_links!
    end

    it "updates the tag mappings with a completion time" do
      allow(Services.publishing_api).to receive(:patch_links)

      expect(TagMapping).to receive(:update_publish_completed_at).with([333])
      expect(TagMapping).to receive(:update_publish_completed_at).with([444, 555])

      publish_content_1_links!
      publish_content_2_links!
    end

    context "when no matching link_content_id is found" do
      it "doesn't do anything" do
        publishing_api_has_lookups("/content-1" => nil)

        expect(Services.publishing_api).to_not receive(:patch_links)
        expect(TagMapping).to_not receive(:update_publish_completed_at)

        publish_content_1_links!
      end
    end
  end
end
