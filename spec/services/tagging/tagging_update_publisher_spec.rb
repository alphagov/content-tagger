require 'rails_helper'

RSpec.describe Tagging::TaggingUpdatePublisher do
  describe '#save_to_publishing_api' do
    before do
      stub_request(:patch, %r{https://publishing-api.test.gov.uk/v2/links/*}).to_return(status: 200)
    end

    it "converts base paths of related items into content IDs" do
      stub_content_id_lookup("/my-page" => "THE-CONTENT-ID-OF-THIS-PAGE")

      update_taggings_with_params(ordered_related_items: ["/my-page"])

      expect_links_to_have_been_published(ordered_related_items: ['THE-CONTENT-ID-OF-THIS-PAGE'])
    end

    it "converts absolute paths of related items into content IDs" do
      stub_content_id_lookup("/my-page" => "THE-CONTENT-ID-OF-THIS-PAGE")

      update_taggings_with_params(ordered_related_items: ["https://www.gov.uk/my-page"])

      expect_links_to_have_been_published(ordered_related_items: ['THE-CONTENT-ID-OF-THIS-PAGE'])
    end

    it "is not valid if the provided base path does not exist" do
      stub_content_id_lookup("/my-page" => nil)

      response = Tagging::TaggingUpdatePublisher.new(
        stubbed_content_item,
        ordered_related_items: ["/my-page"]
      )

      expect(response.save_to_publishing_api).to eql(false)
      expect(response.related_item_errors).to eql("/my-page" => "Not a known URL on GOV.UK")
    end

    def expect_links_to_have_been_published(links)
      expect(stub_request(:patch, %r{https://publishing-api.test.gov.uk/v2/links/*}).with(body: { links: links, previous_version: 0 }.to_json)).to have_been_made
    end

    def update_taggings_with_params(controller_params)
      Tagging::TaggingUpdatePublisher.new(stubbed_content_item, controller_params).save_to_publishing_api
    end

    def stub_content_id_lookup(response = {})
      stub_request(:post, "https://publishing-api.test.gov.uk/lookup-by-base-path")
        .with(body: { "base_paths" => response.keys })
        .to_return(body: response.to_json)
    end

    def stubbed_content_item
      double(content_id: 'some-id', allowed_tag_types: [:ordered_related_items])
    end
  end
end
