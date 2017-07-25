require 'rails_helper'

RSpec.describe LegacyTaxonomy::Client::PublishingApi do
  subject { described_class }

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
