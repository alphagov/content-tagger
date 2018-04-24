require 'rails_helper'

RSpec.describe LegacyTaxonomy::Client::PublishingApi do
  subject { described_class }

  before :each do
    @content_id = '64aadc14-9bca-40d9-abb4-4f21f9792a05'
  end

  it "gets linked items" do
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linked/content_id?fields%5B%5D=base_path&fields%5B%5D=content_id&link_type=link_type")
      .to_return(status: 200, body: [{ 'base_path' => 'path/to/content', 'content_id' => 'content_id' }].to_json)
    expect(subject.get_linked_items('content_id', 'link_type')).to eq([{ 'link' => 'path/to/content', 'content_id' => 'content_id' }])
  end

  describe '#legacy_content_ids' do
    it 'returns no legacy taxons for a taxon' do
      publishing_api_has_expanded_links(
        "content_id" => @content_id,
        "expanded_links" => {}
      )
      expect(subject.legacy_content_ids(@content_id)).to be_empty
    end
    it 'returns a list of legacy taxons' do
      legacy_content_id = "8413047e-570a-448b-b8cb-d288a12807dd"
      publishing_api_has_expanded_links(
        "content_id" => @content_id,
        "expanded_links" => {
          "legacy_taxons" =>
            [{
              "api_path" => "/api/content/browse",
              "content_id" => legacy_content_id
            }],
        }
      )
      expect(subject.legacy_content_ids(@content_id)).to eq [legacy_content_id]
    end
    it "retries three times" do
      stub_any_publishing_api_call.and_raise(GdsApi::HTTPGatewayTimeout).times(2).then.to_return(body: '{}')
      expect { subject.legacy_content_ids(@content_id) }.to_not raise_error

      stub_any_publishing_api_call.and_raise(GdsApi::HTTPGatewayTimeout).times(3).then.to_return(body: '{}')
      expect { subject.legacy_content_ids(@content_id) }.to raise_error(GdsApi::HTTPGatewayTimeout)
    end
  end

  describe '#content_ids_linked_to_taxon' do
    it 'returns all content tagged to content' do
      publishing_api_has_linked_items(
        [{ content_id: 'aaa' }, { content_id: 'bbb' }],
        content_id: @content_id,
        link_type: "taxons",
        fields: ["content_id"]
      )
      expect(subject.content_ids_linked_to_taxon(@content_id)).to eq %w[aaa bbb]
    end
    it "retries three times" do
      stub_any_publishing_api_call.and_raise(GdsApi::HTTPGatewayTimeout).times(2).then.to_return(body: '{}')
      expect { subject.content_ids_linked_to_taxon(@content_id) }.to_not raise_error

      stub_any_publishing_api_call.and_raise(GdsApi::HTTPGatewayTimeout).times(3).then.to_return(body: '{}')
      expect { subject.content_ids_linked_to_taxon(@content_id) }.to raise_error(GdsApi::HTTPGatewayTimeout)
    end
  end

  describe '#all_taxons_content_ids' do
    it 'returns all taxon ids' do
      publishing_api_has_content(
        [{ content_id: 'aaa' }, { content_id: 'bbb' }],
        document_type: 'taxon',
        fields: ['content_id'],
        page: 1,
        states: ['published'],
         )
      expect(subject.all_taxons_content_ids.force).to eq %w[aaa bbb]
    end
  end
end
