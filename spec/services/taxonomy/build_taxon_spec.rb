require 'rails_helper'

RSpec.describe Taxonomy::BuildTaxon do
  describe '.call(content_id:)' do
    let(:content_id) { SecureRandom.uuid }
    let(:content) do
      {
        content_id: content_id,
        title: 'A title',
        description: 'A description',
        base_path: '/foo/bar',
        publication_state: 'State',
        details: {
          internal_name: 'Internal name',
          notes_for_editors: 'Notes for editors',
          visible_to_departmental_editors: true
        }
      }
    end
    let(:taxon) { Taxonomy::BuildTaxon.call(content_id: content_id) }

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
      expect(taxon.title).to eq('A title')
    end

    it 'assigns the description correctly' do
      expect(taxon.description).to eq('A description')
    end

    it 'assigns the base_path correctly' do
      expect(taxon.base_path).to eq(content[:base_path])
    end

    it 'assigns the publication state correctly' do
      expect(taxon.publication_state).to eq(content[:publication_state])
    end

    it 'assigns the internal_name correctly' do
      expect(taxon.internal_name).to eq("Internal name")
    end

    it 'assigns the notes_for_editors correctly' do
      expect(taxon.notes_for_editors).to eq("Notes for editors")
    end

    it "assigns the visible_to_departmental_editors flag correctly" do
      expect(taxon.visible_to_departmental_editors).to be true
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

    context 'with an invalid taxon' do
      before do
        publishing_api_does_not_have_item(content_id)
      end

      it 'raises an exception' do
        expect { taxon }.to raise_error(
          Taxonomy::BuildTaxon::TaxonNotFoundError
        )
      end
    end
  end
end
