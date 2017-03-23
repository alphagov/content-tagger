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
        },
        links: {
          parent_taxons: %w(
            0f27606a-4012-4106-8f50-70ad3c898a0b
            cb000e46-4c16-42fe-bb9c-595a5f9eb677
          ),
        }
      }
    end
    let(:taxon) { Taxonomy::BuildTaxon.call(content_id: content_id) }

    before do
      publishing_api_has_item(content)
    end

    it 'builds a taxon object' do
      expect(taxon).to be_a(Taxon)
    end

    it 'assigns the parents to the taxon' do
      expect(taxon.parent_taxons).to eql(%w(
                                           0f27606a-4012-4106-8f50-70ad3c898a0b
                                           cb000e46-4c16-42fe-bb9c-595a5f9eb677
                                         ))
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
