require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'
include ::GdsApi::TestHelpers::PublishingApiV2

RSpec.describe Tagging::Untagger do
  it 'untags a taxon' do
    content_id = "51ac4247-fd92-470a-a207-6b852a97f2db"
    publishing_api_has_links(
      "content_id" => content_id,
      "links" => {
        "taxons" => ['aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb']
      },
    )

    stub_any_publishing_api_patch_links
    Tagging::Untagger.call(content_id, ['aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'])
    assert_publishing_api_patch_links(content_id, 'links' => { 'taxons' => ['bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'] })
  end
end
