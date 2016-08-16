require 'rails_helper'

RSpec.describe LinksUpdate do
  let(:links_update) do
    build(:links_update, links: { 'taxons' => ['a-taxon-content-id'] })
  end

  describe '#taxons' do
    it 'returns the list of taxons' do
      expect(links_update.taxons).to eq(['a-taxon-content-id'])
    end
  end

  describe '#link_types' do
    it 'returns the list of link types' do
      expect(links_update.link_types).to eq(['taxons'])
    end
  end

  describe '#content_id' do
    it 'finds the content id from the base path' do
      content_id = "content-1-ID"
      publishing_api_has_lookups(links_update.base_path => content_id)

      expect(links_update.content_id).to eq(content_id)
    end
  end

  describe '#mark_as_tagged' do
    let(:tag_mapping) { create(:tag_mapping) }

    before do
      links_update.tag_mappings = TagMapping.all
    end

    it 'marks a number of tag mappings as tagged' do
      expectation = lambda do
        links_update.mark_as_tagged
        tag_mapping.reload
      end

      expect { expectation.call }.to change { tag_mapping.state }.to('tagged')
    end

    it 'adds a publish_completed_at date' do
      expectation = lambda do
        links_update.mark_as_tagged
        tag_mapping.reload
      end

      expect { expectation.call }.to change { tag_mapping.publish_completed_at }
    end
  end

  describe '#mark_as_errored' do
    let(:tag_mapping) { create(:tag_mapping) }

    before do
      links_update.tag_mappings = TagMapping.all
    end

    it 'marks a number of tag mappings as errored' do
      expectation = lambda do
        links_update.mark_as_errored
        tag_mapping.reload
      end

      expect { expectation.call }.to change { tag_mapping.state }.to('errored')
    end

    it 'adds an error message' do
      expectation = lambda do
        links_update.mark_as_errored
        tag_mapping.reload
      end

      expect { expectation.call }.to change { tag_mapping.message }
    end
  end
end
