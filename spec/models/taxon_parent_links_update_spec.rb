require 'rails_helper'

RSpec.describe TaxonParentLinksUpdate do
  describe '#content_id' do
    it 'exposes the content id' do
      links_update = described_class.new('a-content-id')

      expect(links_update.content_id).to eq('a-content-id')
    end
  end

  describe '#links_to_update' do
    it 'includes an empty list of parents to update' do
      links_update = described_class.new('a-content-id')

      expect(links_update.links_to_update).to eq('parent' => [])
    end
  end
end
