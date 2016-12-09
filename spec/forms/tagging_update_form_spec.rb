require 'rails_helper'

RSpec.describe TaggingUpdateForm do
  describe '#links_payload' do
    it 'generates a payload with links' do
      form = TaggingUpdateForm.new(
        topics: ['', '877a4785-bcec-4e23-98b6-1a3a84e33755'],
        mainstream_browse_pages: [''],
        organisations: [''],
        taxons: [''],
        parent: [''],
        ordered_related_items: [''],
      )

      links_payload = form.links_payload

      expect(links_payload).to eql(
        topics: ['877a4785-bcec-4e23-98b6-1a3a84e33755'],
        mainstream_browse_pages: [],
        organisations: [],
        taxons: [],
        parent: [],
        ordered_related_items: [],
      )
    end

    it "does not include a key if it wasn't submitted from the form" do
      form = TaggingUpdateForm.new(
        topics: [],
        organisations: [],
        taxons: [],
      )

      links_payload = form.links_payload

      expect(links_payload).to eql(
        topics: [],
        organisations: [],
        taxons: [],
      )
    end

    it "converts base paths of related items into content IDs" do
      form = TaggingUpdateForm.new(
        ordered_related_items: ['/bank-holidays', '/pay-vat'],
      )

      stub_request(:post, "https://publishing-api.test.gov.uk/lookup-by-base-path")
        .with(body: { "base_paths" => ["/bank-holidays", "/pay-vat"] })
        .to_return(body: {
          "/bank-holidays" => "58f79dbd-e57f-4ab2-ae96-96df5767d1b2",
          "/pay-vat" => "a484eaea-eeb6-48fa-92a7-b67c6cd414f6",
        }.to_json)

      links_payload = form.links_payload

      expect(links_payload).to eql(
        ordered_related_items: [
          "58f79dbd-e57f-4ab2-ae96-96df5767d1b2",
          "a484eaea-eeb6-48fa-92a7-b67c6cd414f6",
        ],
      )
    end

    it "converts absolute paths of related items into content IDs" do
      form = TaggingUpdateForm.new(
        ordered_related_items: [
          'https://www.gov.uk/bank-holidays',
          'https://www-origin.staging.publishing.service.gov.uk/pay-vat',
        ],
      )

      stub_request(:post, "https://publishing-api.test.gov.uk/lookup-by-base-path")
        .with(body: { "base_paths" => ["/bank-holidays", "/pay-vat"] })
        .to_return(body: {
          "/bank-holidays" => "58f79dbd-e57f-4ab2-ae96-96df5767d1b2",
          "/pay-vat" => "a484eaea-eeb6-48fa-92a7-b67c6cd414f6",
        }.to_json)

      links_payload = form.links_payload

      expect(links_payload).to eql(
        ordered_related_items: [
          "58f79dbd-e57f-4ab2-ae96-96df5767d1b2",
          "a484eaea-eeb6-48fa-92a7-b67c6cd414f6",
        ],
      )
    end
  end
end
