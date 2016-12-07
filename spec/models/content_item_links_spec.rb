require 'rails_helper'

RSpec.describe ContentItemLinks do
  describe '#links_payload' do
    it 'generates a payload with links' do
      form = ContentItemLinks.new(
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
      form = ContentItemLinks.new(
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
  end
end
