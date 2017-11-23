require 'rails_helper'
include Taxonomy

RSpec.describe Taxonomy::TaxonomyQuery do
  def query
    TaxonomyQuery.new(%w[content_id base_path])
  end
  describe '#root_taxons' do
    it 'returns an empty array' do
      expect(Services.content_store).to receive(:content_item).with('/').and_return no_taxons
      expect(query.root_taxons).to be_empty
    end

    it 'returns root taxons' do
      expect(Services.content_store).to receive(:content_item).with('/').and_return root_taxons
      expect(query.root_taxons)
        .to match_array [{ 'content_id' => 'rrrr_aaaa', 'base_path' => '/taxons/root_taxon_a' },
                         { 'content_id' => 'rrrr_bbbb', 'base_path' => '/taxons/root_taxon_b' }]
    end
  end

  describe '#child_taxons' do
    it 'returns an empty array' do
      expect(Services.content_store).to receive(:content_item).with('/taxons/root_taxon').and_return no_taxons
      expect(query.child_taxons('/taxons/root_taxon')).to be_empty
    end
    it 'returns an single level of taxons' do
      expect(Services.content_store).to receive(:content_item).with('/taxons/root_taxon').and_return single_level_child_taxons('rrrr', 'aaaa', 'bbbb')
      expect(query.child_taxons('/taxons/root_taxon'))
        .to match_array [{ 'content_id' => 'aaaa', 'base_path' => '/taxons/aaaa', 'parent_content_id' => 'rrrr' },
                         { 'content_id' => 'bbbb', 'base_path' => '/taxons/bbbb', 'parent_content_id' => 'rrrr' }]
    end
    it 'returns multiple levels of taxons' do
      expect(Services.content_store).to receive(:content_item).with('/taxons/root_taxon').and_return multi_level_child_taxons
      expect(query.child_taxons('/taxons/root_taxon'))
        .to match_array [{ 'content_id' => 'aaaa', 'base_path' => '/root_taxon/taxon_a', 'parent_content_id' => 'rrrr' },
                         { 'content_id' => 'aaaa_1111', 'base_path' => '/root_taxon/taxon_1', 'parent_content_id' => 'aaaa' },
                         { 'content_id' => 'aaaa_2222', 'base_path' => '/root_taxon/taxon_2', 'parent_content_id' => 'aaaa' }]
    end
  end

  def multi_level_child_taxons
    {
      "base_path" => "/taxons/root_taxon",
      "content_id" => "rrrr",
      "links" => {
        "child_taxons" => [
          {
            "base_path" => "/root_taxon/taxon_a",
            "content_id" => "aaaa",
            "links" => {
              "child_taxons" => [
                {
                  "base_path" => "/root_taxon/taxon_1",
                  "content_id" => "aaaa_1111",
                  "links" => {}
                },
                {
                  "base_path" => "/root_taxon/taxon_2",
                  "content_id" => "aaaa_2222",
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    }
  end

  def single_level_child_taxons(root, child_1, child_2)
    {
      "base_path" => "/taxons/#{root}",
      "content_id" => root.to_s,
      "links" => {
        "child_taxons" => [
          {
            "base_path" => "/taxons/#{child_1}",
            "content_id" => child_1.to_s,
            "links" => {}
          },
          {
            "base_path" => "/taxons/#{child_2}",
            "content_id" => child_2.to_s,
            "links" => {}
          }
        ]
      }
    }
  end

  def root_taxons
    {
      "base_path" => "/",
      "content_id" => "hhhh",
      "links" => {
        "root_taxons" => [
          {
            "base_path" => "/taxons/root_taxon_a",
            "content_id" => "rrrr_aaaa"
          },
          {
            "base_path" => "/taxons/root_taxon_b",
            "content_id" => "rrrr_bbbb"
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
