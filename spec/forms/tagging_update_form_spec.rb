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
      )

      links_payload = form.links_payload(ContentItemExpandedLinks::TAG_TYPES)

      expect(links_payload).to eql(
        topics: ['877a4785-bcec-4e23-98b6-1a3a84e33755'],
        mainstream_browse_pages: [],
        organisations: [],
        taxons: [],
        parent: [],
      )
    end

    it "treats non-submitted keys as empty if they're not blacklisted" do
      form = TaggingUpdateForm.new(
        topics: [],
        organisations: [],
        taxons: [],
      )

      links_payload = form.links_payload(ContentItemExpandedLinks::TAG_TYPES)

      expect(links_payload).to eql(
        topics: [],
        mainstream_browse_pages: [],
        organisations: [],
        taxons: [],
        parent: [],
      )
    end

    it "does not include blacklisted keys" do
      form = TaggingUpdateForm.new(
        topics: ["877a4785-bcec-4e23-98b6-1a3a84e33755"],
        mainstream_browse_pages: [''],
        organisations: [''],
        taxons: [''],
        parent: [''],
      )

      links_payload = form.links_payload(ContentItemExpandedLinks::TAG_TYPES - [:topics])

      expect(links_payload).to eql(
        mainstream_browse_pages: [],
        organisations: [],
        taxons: [],
        parent: [],
      )
    end
  end
end
