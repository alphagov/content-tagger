require 'rails_helper'

RSpec.describe LegacyTaxonomy::MissingPagesFinder do
  before :each do
    existing_taxon_content_ids(['taxon_content_id'])
    taxon_has_legacy_taxons('taxon_content_id', ['l1'])
    @taxonomy = legacy_taxonomy_with_tagged_pages('l1', [{ 'content_id' => 'p1' }, { 'content_id' => 'p2' }])
  end
  it 'removes taxons without missing pages' do
    taxon_has_tagged_pages('taxon_content_id', %w[p1 p2])
    expect(LegacyTaxonomy::MissingPagesFinder.new.find([@taxonomy])).to be_empty
  end
  it 'returns missing pages' do
    taxon_has_tagged_pages('taxon_content_id', ['p1'])
    expect(LegacyTaxonomy::MissingPagesFinder.new.find([@taxonomy])).to eq([{ taxon_content_id: 'taxon_content_id', missing_pages: ['p2'] }])
  end

  def taxon_has_legacy_taxons(taxon_content_id, legacy_content_ids)
    allow(LegacyTaxonomy::Client::PublishingApi).to receive(:legacy_content_ids).with(taxon_content_id).and_return(legacy_content_ids)
  end

  def existing_taxon_content_ids(taxon_content_ids)
    allow(LegacyTaxonomy::Client::PublishingApi).to receive(:all_taxons_content_ids).and_return(taxon_content_ids)
  end

  def taxon_has_tagged_pages(taxon_content_id, pages)
    allow(LegacyTaxonomy::Client::PublishingApi).to receive(:content_ids_linked_to_taxon).with(taxon_content_id).and_return(pages)
  end

  def legacy_taxonomy_with_tagged_pages(taxon_content_id, pages)
    LegacyTaxonomy::TaxonData.new(legacy_content_id: taxon_content_id, tagged_pages: pages)
  end
end
