require 'rails_helper'

module DataExport
  RSpec.describe TaxonExport do
    describe '#root_taxons' do
      it 'returns an empty array' do
        expect(Services.content_store).to receive(:content_item).with('/').and_return no_taxons
        expect(TaxonExport.new.root_taxons).to be_empty
      end

      it 'returns root taxons' do
        expect(Services.content_store).to receive(:content_item).with('/').and_return root_taxons
        expect(TaxonExport.new.root_taxons)
          .to match_array [{ 'content_id' => 'aaaa', 'base_path' => '/taxons/taxon_a' },
                           { 'content_id' => 'bbbb', 'base_path' => '/taxons/taxon_b' }]
      end
    end

    describe '#branch' do
      it 'returns an empty array' do
        expect(Services.content_store).to receive(:content_item).with('/taxons/root_taxon').and_return no_taxons
        expect(TaxonExport.new.child_taxons('/taxons/root_taxon')).to be_empty
      end
      it 'returns an single level of taxons' do
        expect(Services.content_store).to receive(:content_item).with('/taxons/root_taxon').and_return single_level_child_taxons
        expect(TaxonExport.new.child_taxons('/taxons/root_taxon'))
          .to match_array [{ 'content_id' => 'aaaa', 'base_path' => '/taxons/root_taxon/taxon_a', 'parent_content_id' => 'rrrr' },
                           { 'content_id' => 'bbbb', 'base_path' => '/taxons/root_taxon/taxon_b', 'parent_content_id' => 'rrrr' }]
      end
      it 'returns multiple levels of taxons' do
        expect(Services.content_store).to receive(:content_item).with('/taxons/root_taxon').and_return multi_level_child_taxons
        expect(TaxonExport.new.child_taxons('/taxons/root_taxon'))
          .to match_array [{ 'content_id' => 'aaaa', 'base_path' => '/taxons/root_taxon/taxon_a', 'parent_content_id' => 'rrrr' },
                           { 'content_id' => 'aaaa_1111', 'base_path' => '/taxons/root_taxon/taxon_a/taxon_1', 'parent_content_id' => 'aaaa' },
                           { 'content_id' => 'aaaa_2222', 'base_path' => '/taxons/root_taxon/taxon_a/taxon_2', 'parent_content_id' => 'aaaa' }]
      end
    end

    def multi_level_child_taxons
      {
        "content_id" => "rrrr",
        "base_path" => "/taxons/root_taxon",
        "title" => "Root Taxon",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/taxons/root_taxon/taxon_a",
              "content_id" => "aaaa",
              "description" => "Taxon A",
              "links" => {
                "child_taxons" => [
                  {
                    "base_path" => "/taxons/root_taxon/taxon_a/taxon_1",
                    "content_id" => "aaaa_1111",
                    "description" => "Taxon A 1",
                    "links" => {}
                  },
                  {
                    "base_path" => "/taxons/root_taxon/taxon_a/taxon_2",
                    "content_id" => "aaaa_2222",
                    "description" => "Taxon A 2",
                    "links" => {}
                  }
                ]
              }
            }
          ]
        }
      }
    end

    def single_level_child_taxons
      {
        "content_id" => "rrrr",
        "base_path" => "/taxons/root_taxon",
        "title" => "Root Taxon",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/taxons/root_taxon/taxon_a",
              "content_id" => "aaaa",
              "description" => "Taxon A",
              "links" => {}
            },
            {
              "base_path" => "/taxons/root_taxon/taxon_b",
              "content_id" => "bbbb",
              "description" => "Taxon B",
              "links" => {}
            }
          ]
        }
      }
    end

    def root_taxons
      {
        "base_path" => "/",
        "content_id" => "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a",
        "links" => {
          "root_taxons" => [
            {
              "base_path" => "/taxons/taxon_a",
              "content_id" => "aaaa"
            },
            {
              "base_path" => "/taxons/taxon_b",
              "content_id" => "bbbb"
            }
          ],
        }
      }
    end

    def no_taxons
      {
        "base_path" => "/",
        "content_id" => "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a"
      }
    end
  end
end
