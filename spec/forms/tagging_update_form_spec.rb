require 'rails_helper'

RSpec.describe TaggingUpdateForm do
  describe '#links_payload' do
    it 'generates a payload with links' do
      form = TaggingUpdateForm.new(
        topics: ['', '877a4785-bcec-4e23-98b6-1a3a84e33755'],
        mainstream_browse_pages: [''],
        organisations: [''],
        alpha_taxons: [''],
        parent: [''],
      )

      links_payload = form.links_payload

      expect(links_payload).to eql(
        topics: ['877a4785-bcec-4e23-98b6-1a3a84e33755'],
        mainstream_browse_pages: [],
        organisations: [],
        alpha_taxons: [],
        parent: [],
      )
    end

    it 'does not include parent if parent is not in the form list' do
      form = TaggingUpdateForm.new(
        topics: [],
        organisations: [],
        alpha_taxons: [],
      )

      links_payload = form.links_payload

      expect(links_payload).to eql(
        topics: [],
        mainstream_browse_pages: [],
        organisations: [],
        alpha_taxons: [],
      )
    end
  end
end
