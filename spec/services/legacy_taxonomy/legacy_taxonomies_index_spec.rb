require 'rails_helper'

RSpec.describe LegacyTaxonomy::LegacyTaxonomiesIndex do
  describe "#tagged_pages" do
    context 'A single taxon data' do
      before :each do
        @tagging_index = LegacyTaxonomy::LegacyTaxonomiesIndex.new([taxon_data(123, [1, 2, 3])])
      end
      it 'returns the tagged pages' do
        expect(@tagging_index.tagged_pages(123)).to eq([1, 2, 3])
      end
      it 'cannot find the page and returns an empty array' do
        expect(@tagging_index.tagged_pages(234)).to eq([])
      end
    end
    context 'A hierarchy of taxondatas' do
      before :each do
        @tagging_index = LegacyTaxonomy::LegacyTaxonomiesIndex.new([taxon_data(0),
                                                                    taxon_data(-1, [],
                                                                               [taxon_data(-2),
                                                                                taxon_data(123, [1, 2, 3])])])
      end
      it 'returns the tagged pages' do
        expect(@tagging_index.tagged_pages(123)).to eq([1, 2, 3])
      end
    end

    def taxon_data(content_id, tagged_pages = [], children = [])
      LegacyTaxonomy::TaxonData.new(legacy_content_id: content_id, tagged_pages: tagged_pages, child_taxons: children)
    end
  end
end
