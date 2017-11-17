require 'rails_helper'

RSpec.describe Taxonomy::PublishTaxon do
  let(:parent_taxon) do
    Taxon.new(
      content_id: '1234',
      title: 'Parent taxon',
      visible_to_departmental_editors: false,
    )
  end

  let(:taxon) do
    Taxon.new(
      content_id: '5678',
      title: 'Taxon',
      parent: parent_taxon,
      visible_to_departmental_editors: false,
    )
  end

  describe '#call' do
    it 'sends publish request to publishing api' do
      expect(Services.publishing_api).to receive(:publish).with(taxon.content_id)
      Taxonomy::PublishTaxon.call(taxon)
    end

    context 'when publishing a branch root taxon' do
      context 'when visible_to_department_editors is false' do
        it 'sets visible_to_department_editors field to true' do
          expect(Taxonomy::UpdateTaxon).to receive(:call).with(taxon: parent_taxon)
          expect(Services.publishing_api).to receive(:publish).with(parent_taxon.content_id)
          Taxonomy::PublishTaxon.call(parent_taxon)

          expect(parent_taxon.visible_to_departmental_editors).to be_truthy
        end
      end
    end
  end
end
