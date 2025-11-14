RSpec.describe Tagging::TaggingUpdatePublisher do
  describe "#save_to_publishing_api" do
    before do
      stub_request(:patch, %r{https://publishing-api.test.gov.uk/v2/links/*}).to_return(status: 200)
    end

    let(:content_id) { "2797b5f2-7154-411e-9282-7756b78b22d6" }

    let(:stubbed_content_item) do
      instance_double(
        ContentItem,
        content_id:,
        allowed_tag_types: %i[ordered_related_items ordered_related_items_overrides],
      )
    end

    it "converts base paths of related items into content IDs" do
      stub_content_id_lookup("/my-page" => content_id)

      update_taggings_with_params(ordered_related_items: ["/my-page"], ordered_related_items_overrides: ["/my-page"])

      expect_links_to_have_been_published(ordered_related_items: [content_id], ordered_related_items_overrides: [content_id])
    end

    it "generates a valid links payload using ordered_related_items and overrides" do
      stub_content_id_lookup("/my-page" => content_id)

      publisher = described_class.new(
        stubbed_content_item,
        taxons: %w[0ffd5e18-af20-4413-a215-8511cf7628b5],
        ordered_related_items: ["/my-page"],
        ordered_related_items_overrides: ["/my-page"],
      )

      expect(links: publisher.generate_links_payload).to be_valid_against_links_schema("publication")
    end

    it "converts absolute paths of related items into content IDs" do
      stub_content_id_lookup("/my-page" => content_id)

      update_taggings_with_params(ordered_related_items: ["https://www.gov.uk/my-page"])

      expect_links_to_have_been_published(ordered_related_items: [content_id], ordered_related_items_overrides: [])
    end

    it "is not valid if the provided base path does not exist" do
      stub_content_id_lookup("/my-page" => nil)

      response = described_class.new(
        stubbed_content_item,
        ordered_related_items: ["/my-page"],
      )

      expect(response.save_to_publishing_api).to be(false)
      expect(response.related_item_errors).to eql("/my-page" => "Not a known URL on GOV.UK")
    end

    def expect_links_to_have_been_published(links)
      expect(stub_request(:patch, %r{https://publishing-api.test.gov.uk/v2/links/*}).with(body: { links:, previous_version: 0 }.to_json)).to have_been_made
    end

    def update_taggings_with_params(controller_params)
      Tagging::TaggingUpdatePublisher.new(stubbed_content_item, controller_params).save_to_publishing_api
    end

    def stub_content_id_lookup(response = {})
      stub_request(:post, "https://publishing-api.test.gov.uk/lookup-by-base-path")
        .with(body: { "base_paths" => response.keys })
        .to_return(body: response.to_json)
    end
  end
end
