require 'rails_helper'

RSpec.describe LegacyTaxonomy::Client::PublishingApi do
  subject { described_class }

  it "gets linked items" do
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linked/content_id?fields%5B%5D=base_path&fields%5B%5D=content_id&link_type=link_type")
      .to_return(status: 200, body: [{ 'base_path' => 'path/to/content', 'content_id' => 'content_id' }].to_json)
    expect(subject.get_linked_items('content_id', 'link_type')).to eq([{ 'link' => 'path/to/content', 'content_id' => 'content_id' }])
  end
end
