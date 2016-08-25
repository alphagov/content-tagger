require 'rails_helper'

RSpec.describe Taxonomy::TaxonBuilder do
  let(:builder) { described_class.new(content_id: content_id) }

  describe '#build' do
    let(:content_id) { SecureRandom.uuid }
    let(:content) do
      {
        content_id: content_id,
        title: 'A title',
        base_path: 'A base path',
        publication_state: 'State',
        internal_name: 'Internal name'
      }
    end
    let(:taxon) { builder.build }

    before do
      publishing_api_has_item(content)
      publishing_api_has_links(
        content_id: content_id,
        links: {
          topics: [],
          parent_taxons: []
        }
      )
    end

    it 'builds a taxon object' do
      expect(taxon).to be_a(Taxon)
    end

    it 'assigns the parents to the taxon' do
      expect(taxon.parent_taxons).to be_empty
    end

    it 'assigns the content id correctly' do
      expect(taxon.content_id).to eq(content_id)
    end

    it 'assigns the title correctly' do
      expect(taxon.title).to eq(content[:title])
    end

    it 'assigns the base_path correctly' do
      expect(taxon.base_path).to eq(content[:base_path])
    end

    it 'assigns the publication state correctly' do
      expect(taxon.publication_state).to eq(content[:publication_state])
    end

    it 'assigns the internal_name correctly' do
      expect(taxon.internal_name).to eq(content[:internal_name])
    end

    context 'without taxon parents' do
      before do
        publishing_api_has_links(
          content_id: content_id,
          links: {
            topics: []
          }
        )
      end

      it 'has no taxon parents' do
        expect(taxon.parent_taxons).to be_empty
      end
    end

    context 'with existing links' do
      let(:parent_taxons) { ["CONTENT-ID-RTI", "CONTENT-ID-VAT"] }
      before do
        publishing_api_has_links(
          content_id: content_id,
          links: {
            topics: [],
            parent_taxons: parent_taxons
          }
        )
      end

      it 'assigns the parents to the taxon' do
        expect(taxon.parent_taxons).to eq(parent_taxons)
      end
    end
  end
end
