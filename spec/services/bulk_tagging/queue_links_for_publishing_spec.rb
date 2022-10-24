module BulkTagging
  RSpec.describe QueueLinksForPublishing do
    let(:tagging_spreadsheet) do
      create(
        :tagging_spreadsheet,
        state: "uploaded",
        tag_mappings: [tag_mapping_1, tag_mapping_2, tag_mapping_3],
      )
    end
    let(:user) { instance_double(User, uid: "user-123") }
    let(:tag_mapping_1) do
      create(
        :tag_mapping,
        content_base_path: "/content-1",
        link_title: "GDS",
        link_content_id: "gds-ID",
        link_type: "organisations",
      )
    end
    let(:tag_mapping_2) do
      create(
        :tag_mapping,
        content_base_path: "/content-1",
        link_title: "Education",
        link_content_id: "education-ID",
        link_type: "taxons",
      )
    end
    let(:tag_mapping_3) do
      create(
        :tag_mapping,
        content_base_path: "/content-2",
        link_title: "Education",
        link_content_id: "education-ID",
        link_type: "taxons",
      )
    end

    describe ".call" do
      it "published the links for the 3 tag mapping records" do
        allow(Time.zone).to receive(:now).and_return(Time.zone.local(0))

        expect(PublishLinksWorker).to receive(:perform_async)
          .with(tag_mapping_1.id)
        expect(PublishLinksWorker).to receive(:perform_async)
          .with(tag_mapping_2.id)
        expect(PublishLinksWorker).to receive(:perform_async)
          .with(tag_mapping_3.id)

        described_class.call(tagging_spreadsheet, user:)

        expect(tagging_spreadsheet.last_published_by).to eq "user-123"
        expect(tagging_spreadsheet.last_published_at).to eq Time.zone.local(0)
      end
    end
  end
end
