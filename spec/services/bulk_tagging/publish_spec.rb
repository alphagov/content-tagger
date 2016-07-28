require 'rails_helper'

RSpec.describe BulkTagging::Publish do
  let(:tagging_spreadsheet) { TaggingSpreadsheet.create(url: "https://tagging/spreadsheet/") }
  let(:user) { double(uid: "user-123") }

  describe "#run" do
    it "it constructs link payloads from tag mappings and publishes them" do
      tagging_spreadsheet.tag_mappings.create(
        content_base_path: "/content-1", link_title: "GDS",
        link_content_id: "gds-ID", link_type: "organisations"
      )
      tagging_spreadsheet.tag_mappings.create(
        content_base_path: "/content-1", link_title: "GDS",
        link_content_id: "gds-ID", link_type: "organisations"
      )
      tagging_spreadsheet.tag_mappings.create(
        content_base_path: "/content-1", link_title: "Education",
        link_content_id: "education-ID", link_type: "taxons"
      )
      tagging_spreadsheet.tag_mappings.create(
        content_base_path: "/content-2", link_title: "Education",
        link_content_id: "education-ID", link_type: "taxons"
      )
      publishing_api_has_lookups("/content-1" => "content-1-ID", "/content-2" => "content-2-ID")
      api_response = double(code: 200)
      allow(Time.zone).to receive(:now).and_return(Time.new(0))

      expected_links_1 = {
        "taxons" => ["education-ID"], "organisations" => ["gds-ID", "gds-ID"]
      }
      expected_links_2 = {
        "taxons" => ["education-ID"]
      }
      expect(Services.publishing_api).to receive(:patch_links)
        .with("content-1-ID", links: expected_links_1)
        .and_return(api_response)
      expect(Services.publishing_api).to receive(:patch_links)
        .with("content-2-ID", links: expected_links_2)
        .and_return(api_response)

      BulkTagging::Publish.new(tagging_spreadsheet, user: user).run

      expect(TaggingSpreadsheet.first.last_published_by).to eq "user-123"
      expect(TaggingSpreadsheet.first.last_published_at).to eq Time.new(0)
    end

    context "when no matching link_content_id is found" do
      it "doesn't send anything to the publishing API" do
        publishing_api_has_lookups("/content-1" => nil)
        tagging_spreadsheet.tag_mappings.create(
          content_base_path: "/content-1", link_title: "GDS",
          link_content_id: "gds-ID", link_type: "organisations"
        )

        expect(Services.publishing_api).to_not receive(:patch_links)

        BulkTagging::Publish.new(tagging_spreadsheet, user: user).run
      end
    end
  end
end
