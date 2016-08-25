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
    let!(:tag_mapping) { create(:tag_mapping) }

    before do
      publishing_api_has_lookups('/my-base-path' => 'my-content-id')

      publishing_api_has_linkables(
        [
          { 'title' => 'Early Years', content_id: 'my-content-id' },
        ],
        document_type: 'taxon'
      )
    end

    it 'adds error message for invalid link type' do
      links_update = build(:links_update, links: { 'invalid' => ['my-content-id'] })
      links_update.tag_mappings = TagMapping.all

      links_update.valid?
      links_update.mark_as_errored
      tag_mapping.reload

      expect(tag_mapping.state).to eql('errored')
      expect(tag_mapping.message).to_not match(/^Link types/)
      expect(tag_mapping.message).to match(/invalid link types found/i)
    end

    it 'adds error message for content not found' do
      links_update = build(:links_update, links: { 'taxons' => ['a-taxon-content-id'] })
      links_update.tag_mappings = TagMapping.all

      links_update.valid?
      links_update.mark_as_errored
      tag_mapping.reload

      expect(tag_mapping.state).to eql('errored')
      expect(tag_mapping.message).to_not match(/^Content We could not find/)
      expect(tag_mapping.message).to match(/we could not find this url/i)
    end
  end
end
