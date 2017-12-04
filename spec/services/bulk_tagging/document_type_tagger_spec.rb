require 'rails_helper'
include GdsApi::TestHelpers::PublishingApiV2

RSpec.describe BulkTagging::DocumentTypeTagger do
  it 'cannot find a taxon and raises an error' do
    publishing_api_has_lookups("/path/to/taxon" => nil)
    expect { BulkTagging::DocumentTypeTagger.call(taxon_base_path: '/nowhere', document_type: 'document_type') }
            .to raise_error(StandardError, /Cannot find taxon with base path/)
  end
  context 'there is a taxon, some content and links' do
    before :each do
      @taxon_content_id = "51ac4247-fd92-470a-a207-6b852a97f2db"
      publishing_api_has_lookups("/path/to/taxon" => @taxon_content_id)
      publishing_api_has_content([{ 'content_id' => 'c1' }, { 'content_id' => 'c2' }],
                                 page: 1,
                                 document_type: 'document_type',
                                 fields: ['content_id'])

      publishing_api_has_links(
        content_id: 'c1',
        links: {
          taxons: ["569a9ee5-c195-4b7f-b9dc-edc17a09113f"]
        },
        version: 6
      )
      publishing_api_has_links(
        "content_id": 'c2',
        "links": {},
        "version": 10
      )
    end
    it 'returns two error messages' do
      stub_any_publishing_api_patch_links.to_return(status: 404)

      expect(BulkTagging::DocumentTypeTagger.call(taxon_base_path: '/path/to/taxon', document_type: 'document_type').force)
        .to match_array([{ status: 'error', message: /Response body/, content_id: 'c1', new_taxons: [] },
                         { status: 'error', message: /Response body/, content_id: 'c2', new_taxons: [] }])
    end
    it 'it tags two content items' do
      stub_any_publishing_api_patch_links

      expect(BulkTagging::DocumentTypeTagger.call(taxon_base_path: '/path/to/taxon', document_type: 'document_type').force)
        .to match_array([{ status: 'success', message: 'success', content_id: 'c1', new_taxons: ["569a9ee5-c195-4b7f-b9dc-edc17a09113f", @taxon_content_id] },
                         { status: 'success', message: 'success', content_id: 'c2', new_taxons: [@taxon_content_id] }])

      assert_publishing_api_patch_links('c1',
                                        links: { taxons: ["569a9ee5-c195-4b7f-b9dc-edc17a09113f", @taxon_content_id] },
                                        previous_version: 6)
      assert_publishing_api_patch_links('c2',
                                        links: { taxons: [@taxon_content_id] },
                                        previous_version: 10)
    end
  end
end
