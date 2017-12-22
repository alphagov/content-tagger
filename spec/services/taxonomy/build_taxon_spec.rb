require 'rails_helper'

RSpec.describe Taxonomy::BuildTaxon do
  describe '.call(content_id:)' do
    let(:document_type) { 'taxon' }
    let(:content_id) { SecureRandom.uuid }
    let(:content) do
      {
        content_id: content_id,
        title: 'A title',
        description: 'A description',
        document_type: document_type,
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

    it 'assigns the parent to the taxon' do
      expect(taxon.parent).to be_nil
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

      it 'has no taxon parent' do
        expect(taxon.parent).to be_nil
      end
    end

    context 'with existing links' do
      let(:parent_taxon) { "CONTENT-ID-RTI" }
      before do
        publishing_api_has_links(
          content_id: content_id,
          links: {
            topics: [],
            parent_taxons: Array(parent_taxon)
          }
        )
      end

      it 'assigns the parent to the taxon' do
        expect(taxon.parent).to eq(parent_taxon)
      end
    end

    context 'root taxon' do
      before do
        publishing_api_has_links(
          content_id: content_id,
          links: {
            topics: [],
            parent_taxons: [],
            root_taxon: [GovukTaxonomy::ROOT_CONTENT_ID],
          }
        )
      end

      it 'sets the parent to the root taxon id' do
        expect(taxon.parent).to eq(GovukTaxonomy::ROOT_CONTENT_ID)
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

    context 'with a content item that is not a taxon or homepage' do
      let(:document_type) { 'guidance' }

      it 'raises an exception' do
        expect { taxon }.to raise_error(
          Taxonomy::BuildTaxon::DocumentTypeError
        )
      end
    end
  end
end
