require 'rails_helper'

RSpec.describe Taxonomy::TaxonFormBuilder do
  let(:builder) { described_class.new(content_id: content_id) }

  describe '#build' do
    let(:content_id) { SecureRandom.uuid }
    let(:content) do
      {
        content_id: content_id,
        title: 'A title',
        base_path: 'A base path'
      }
    end
    let(:taxon_form) { builder.build }

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

    it 'builds a taxon form object' do
      expect(taxon_form).to be_a(TaxonForm)
    end

    it 'assigns the parents to the form' do
      expect(taxon_form.parent_taxons).to be_empty
    end

    it 'assigns the content id correctly' do
      expect(taxon_form.content_id).to eq(content_id)
    end

    it 'assigns the title correctly' do
      expect(taxon_form.title).to eq(content[:title])
    end

    it 'assigns the base_path correctly' do
      expect(taxon_form.base_path).to eq(content[:base_path])
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
        expect(taxon_form.parent_taxons).to be_empty
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

      it 'assigns the parents to the form' do
        expect(taxon_form.parent_taxons).to eq(parent_taxons)
      end
    end
  end
end
