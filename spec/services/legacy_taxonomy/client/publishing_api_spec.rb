require 'rails_helper'

RSpec.describe LegacyTaxonomy::Client::PublishingApi do
  subject { described_class }

  it "gets linked items" do
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linked/content_id?fields%5B%5D=base_path&fields%5B%5D=content_id&link_type=link_type")
      .to_return(status: 200, body: [{ 'base_path' => 'path/to/content', 'content_id' => 'content_id' }].to_json)
    expect(subject.get_linked_items('content_id', 'link_type')).to eq([{ 'link' => 'path/to/content', 'content_id' => 'content_id' }])
  end

  describe "proxies to a publishing api client" do
    let(:mock_client) { instance_double(GdsApi::PublishingApiV2) }

    before do
      allow(subject).to receive(:client).and_return(mock_client)
    end

    it ".put_content" do
      expect(mock_client)
        .to receive(:put_content)
        .with('foo', {})

      subject.put_content('foo', {})
    end

    it ".publish" do
      expect(mock_client)
        .to receive(:publish)
        .with('foo')

      subject.publish('foo')
    end

    it ".patch_links" do
      expect(mock_client)
        .to receive(:patch_links)
        .with('foo', {})

      subject.patch_links('foo', {})
    end

    it ".get_links" do
      expect(mock_client)
        .to receive(:get_links)
        .with('foo')

      subject.get_links('foo')
    end
  end
end
