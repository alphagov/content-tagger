RSpec.describe Tagging::Tagger do
  subject { described_class }

  let(:content_id) { "64aadc14-9bca-40d9-abb4-4f21f9792a05" }

  describe ".add_tags" do
    it "tags content to taxons" do
      stub_publishing_api_has_links(content_id:, links: { taxons: %w[aaa bbb] }, version: 5)
      stub_any_publishing_api_patch_links
      subject.add_tags(content_id, %w[ccc ddd], :taxons)
      assert_publishing_api_patch_links(content_id, links: { taxons: %w[aaa bbb ccc ddd] }, previous_version: 5, bulk_publishing: true)
    end

    it "tags content to organisations" do
      stub_publishing_api_has_links(content_id:, links: { organisations: %w[gds fco] }, version: 5)
      stub_any_publishing_api_patch_links
      subject.add_tags(content_id, %w[dfid dwp], :organisations)
      assert_publishing_api_patch_links(content_id, links: { organisations: %w[gds fco dfid dwp] }, previous_version: 5, bulk_publishing: true)
    end

    it "retries 3 times" do
      stub_publishing_api_has_links(content_id:, links: { taxons: %w[aaa bbb] }, version: 5)

      stub_any_publishing_api_patch_links.and_raise(GdsApi::HTTPConflict).times(2).then.to_return(body: "{}")
      expect { subject.add_tags(content_id, %w[ccc], :taxons) }.not_to raise_error

      stub_any_publishing_api_patch_links.and_raise(GdsApi::HTTPConflict).times(3).then.to_return(body: "{}")
      expect { subject.add_tags(content_id, %w[ccc], :taxons) }.to raise_error(GdsApi::HTTPConflict)
    end
  end
end
