require 'rails_helper'

RSpec.describe PublishTags do
  let(:tagging_spreadsheet) { create(:tagging_spreadsheet, state: "uploaded") }
  let(:user) { double(uid: "user-123") }

  before do
    create(
      :tag_mapping,
      tagging_source: tagging_spreadsheet,
      content_base_path: "/content-1",
      link_title: "GDS",
      link_content_id: "gds-ID",
      link_type: "organisations"
    )

    create(
      :tag_mapping,
      tagging_source: tagging_spreadsheet,
      content_base_path: "/content-1",
      link_title: "GDS",
      link_content_id: "gds-ID",
      link_type: "organisations"
    )

    create(
      :tag_mapping,
      tagging_source: tagging_spreadsheet,
      content_base_path: "/content-1",
      link_title: "Education",
      link_content_id: "education-ID",
      link_type: "taxons"
    )

    create(
      :tag_mapping,
      tagging_source: tagging_spreadsheet,
      content_base_path: "/content-2",
      link_title: "Education",
      link_content_id: "education-ID",
      link_type: "taxons"
    )
  end

  describe "#run" do
    it "constructs link payloads from tag mappings and queues them for publishing" do
      allow(Time.zone).to receive(:now).and_return(Time.new(0))
      links_payload_1 = {
        "tag_mapping_ids" => TagMapping.where(content_base_path: "/content-1").pluck(:id),
        "taxons" => ["education-ID"],
        "organisations" => ["gds-ID", "gds-ID"]
      }
      links_payload_2 = {
        "tag_mapping_ids" => TagMapping.where(content_base_path: "/content-2").pluck(:id),
        "taxons" => ["education-ID"]
      }

      expect(PublishLinksWorker).to receive(:perform_async).with("/content-1", links_payload_1)
      expect(PublishLinksWorker).to receive(:perform_async).with("/content-2", links_payload_2)

      described_class.new(tagging_spreadsheet, user: user).run

      expect(tagging_spreadsheet.last_published_by).to eq "user-123"
      expect(tagging_spreadsheet.last_published_at).to eq Time.new(0)
    end
  end
end
