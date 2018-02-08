require 'rails_helper'

RSpec.describe Taxonomy::UpdateTaxon do
  before do
    @taxon = Taxon.new(
      title: 'A Title',
      document_type: 'taxon',
      description: 'Description',
      base_path: '/education/slug',
      parent: 'guid',
      associated_taxons: ['1234']
    )
    allow(Taxonomy::SaveTaxonVersion).to receive(:call)
  end
  let(:publish) { described_class.call(taxon: @taxon) }

  describe '.call' do
    context 'with a valid taxon form' do
      it 'publishes the document via the publishing API' do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links

        publish

        assert_publishing_api_put_content(@taxon.content_id)
        assert_publishing_api_patch_links(@taxon.content_id, links: {
                                            root_taxon: [],
                                            parent_taxons: ['guid'],
                                            associated_taxons: ['1234'],
                                          })
      end
    end

    context "when the taxon has no parent" do
      before { @taxon.parent = "" }

      it "patches the links hash with an empty array" do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links

        publish
        assert_publishing_api_patch_links(@taxon.content_id, links: {
                                            root_taxon: [],
                                            parent_taxons: [],
                                            associated_taxons: ['1234'],
                                          })
      end
    end

    context "when the taxon has no associated taxons" do
      before { @taxon.associated_taxons = [] }

      it "patches the links hash with an empty array" do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links

        publish
        assert_publishing_api_patch_links(@taxon.content_id, links: {
                                            root_taxon: [],
                                            parent_taxons: ['guid'],
                                            associated_taxons: [],
                                          })
      end
    end

    context "when the taxon has nil for associated taxons" do
      before { @taxon.associated_taxons = nil }

      it "patches the links hash with an empty array" do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links

        publish
        assert_publishing_api_patch_links(@taxon.content_id, links: {
                                            root_taxon: [],
                                            parent_taxons: ['guid'],
                                            associated_taxons: [],
                                          })
      end
    end

    context 'with an unprocessable entity error from the API' do
      let(:error) do
        GdsApi::HTTPUnprocessableEntity.new(
          422,
          "An internal error message",
          'error' => { 'message' => 'Some backend error' }
        )
      end

      before do
        allow(Services.publishing_api).to receive(:put_content).and_raise(error)
      end

      it 'raises an error with a generic message and notifies GovukError if it is not a base path conflict' do
        publishing_api_has_lookups('')
        expect(GovukError).to receive(:notify).with(error)
        expect { publish }.to raise_error(
          Taxonomy::UpdateTaxon::InvalidTaxonError,
          /there was a problem with your request/i
        )
      end

      it 'raises an error with a specific message if it is a base path conflict' do
        publishing_api_has_lookups(SecureRandom.uuid)
        allow(Services.publishing_api).to receive(:lookup_content_id).and_return(SecureRandom.uuid)
        expect { publish }.to raise_error(
          Taxonomy::UpdateTaxon::InvalidTaxonError,
          /<a href="(.+)">taxon<\/a> with this slug already exists/
        )
      end
    end
  end
end
