require "rails_helper"

RSpec.describe Facets::FacetsTaggingNotificationPresenter do
  let(:content_item) do
    double(
      :content_item,
      base_path: "/my-content-item",
      content_id: "MY-CONTENT-ID",
      description: "This describes my content item",
      document_type: "guide",
      title: 'This Is A Content Item',
    )
  end

  let(:message) { "Retagged!" }

  let(:links) do
    {
      facet_groups: ["FACET-GROUP-UUID"],
      facet_values: ["ANOTHER-FACET-VALUE-UUID", "EXISTING-FACET-VALUE-UUID"],
    }
  end

  subject(:presenter) { described_class.new(content_item, message, links) }

  describe "#present" do
    let(:expected_payload) do
      {
        base_path: "/my-content-item",
        change_note: "Retagged!",
        content_id: "MY-CONTENT-ID",
        description: "This describes my content item",
        document_type: "guide",
        email_document_supertype: "other",
        government_document_supertype: "other",
        links: links,
        priority: "high",
        public_updated_at: "2019-04-12T15:05:59+00:00",
        publishing_app: "content-tagger",
        subject: 'This Is A Content Item',
        tags: links,
        title: 'This Is A Content Item',
        urgent: true,
      }
    end

    it "presents a payload combining content item and links attributes" do
      Timecop.freeze("2019-04-12T15:05:59+00:00") do
        expect(presenter.present).to eq(expected_payload)
      end
    end
  end
end
