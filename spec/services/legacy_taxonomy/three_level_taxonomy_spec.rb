require 'rails_helper'

RSpec.describe LegacyTaxonomy::ThreeLevelTaxonomy do
  before do
    stub_publishing_api_root_taxon
  end

  describe "#to_taxonomy_branch" do
    let(:result) do
      described_class.new('/foo',
                          base_path: '/browse',
                          title: 'taxonomy title',
                          first_level_key: 'top_level_browse_pages',
                          second_level_key: 'second_level_browse_pages').to_taxonomy_branch
    end

    context 'there is only one root, no children' do
      before do
        stub_publishing_api_top_level_browse_pages([])
      end

      it 'returns the root browse taxon' do
        expect(result.title).to eq 'taxonomy title'
        expect(result.base_path).to eq '/foo/browse'
        expect(result.child_taxons).to be_empty
      end
    end

    context 'there are children of the root taxon, no second level taxons' do
      before do
        stub_publishing_api_top_level_browse_pages([basic_taxon])
        stub_nil_second_level_browse_pages(basic_taxon['content_id'])
      end

      it 'has first level taxons' do
        expect(result.child_taxons).to be_an Array
        child_taxon = result.child_taxons.first
        expect(child_taxon.child_taxons).to be_empty
        expect(child_taxon.title).to eq "foo"
        expect(child_taxon.description).to eq "bar"
        expect(child_taxon.base_path).to eq "/foo/path"
      end
    end

    context 'there are second level taxons' do
      before do
        stub_publishing_api_top_level_browse_pages([basic_taxon])
        stub_publishing_api_second_level_browse_pages(basic_taxon['content_id'], [subtaxon])
        stub_publishing_api_third_level_browse_pages(subtaxon['content_id'], [])
        stub_publishing_api_content_id_lookup("/foo/subpath", 'sub_taxon')
        stub_search_api subtaxon, %w(page_content_id)
      end

      it 'has second level taxons' do
        expect(result.child_taxons).to be_an Array
        expect(result.child_taxons.first.child_taxons).to be_an Array
        child_taxon = result.child_taxons.first.child_taxons.first
        expect(child_taxon.child_taxons).to be_empty
        expect(child_taxon.content_id).to eq subtaxon['content_id']
        expect(child_taxon.tagged_pages).to eq %w(page_content_id)
      end
    end

    context "there are third level taxons" do
      before do
        stub_publishing_api_top_level_browse_pages([basic_taxon])
        stub_publishing_api_second_level_browse_pages(basic_taxon['content_id'], [subtaxon])
        stub_publishing_api_third_level_browse_pages(subtaxon['content_id'], content_groups)
        stub_publishing_api_content_id_lookup('/path-of-group-contents', 'content-id-goes-here')
        stub_publishing_api_content_id_lookup_404('/foo/path/groupo_uno')
        stub_search_api subtaxon, %w(page_content_id)
      end

      it "has third level taxons" do
        l3_taxon = result.child_taxons.first.child_taxons.first.child_taxons.first
        expect(l3_taxon.title).to eq 'groupo_uno'
        expect(l3_taxon.tagged_pages).to eq [
          {
            'link' => '/path-of-group-contents',
            'content_id' => 'content-id-goes-here'
          }
        ]
      end
    end
  end

  ####################
  #  HELPER METHODS  #
  ####################

  def stub_publishing_api_root_taxon
    allow(LegacyTaxonomy::Client::PublishingApi)
      .to receive(:content_id_for_base_path)
      .with('/browse')
      .and_return root_browse_page_content_id
  end

  def stub_publishing_api_content_id_lookup(path, content_id)
    allow(LegacyTaxonomy::Client::PublishingApi)
      .to receive(:content_id_for_base_path)
      .with(path)
      .and_return content_id
  end

  def stub_publishing_api_content_id_lookup_404(path)
    allow(LegacyTaxonomy::Client::PublishingApi)
      .to receive(:content_id_for_base_path)
      .with(path)
      .and_return nil
  end

  def stub_publishing_api_top_level_browse_pages(pages_hash)
    allow(LegacyTaxonomy::Client::PublishingApi)
      .to receive(:get_expanded_links)
      .with(root_browse_page_content_id)
      .and_return("top_level_browse_pages" => pages_hash)
  end

  def stub_publishing_api_second_level_browse_pages(parent_id, pages)
    allow(LegacyTaxonomy::Client::PublishingApi)
      .to receive(:get_expanded_links)
      .with(parent_id)
      .and_return("second_level_browse_pages" => pages)

    pages.each do |page|
      allow(LegacyTaxonomy::Client::PublishingApi)
        .to receive(:get_expanded_links)
        .with(page['content_id'])
        .and_return("related_topics" => [])
    end
  end

  def stub_publishing_api_third_level_browse_pages(parent_id, groups)
    allow(LegacyTaxonomy::Client::PublishingApi)
      .to receive(:get_content_groups)
      .with(parent_id)
      .and_return(groups)
  end

  def stub_nil_second_level_browse_pages(parent_id)
    stub_publishing_api_second_level_browse_pages(parent_id, [])
  end

  def stub_search_api(taxon, pages = [])
    allow(LegacyTaxonomy::Client::SearchApi)
      .to receive(:content_tagged_to_browse_page)
      .with(taxon['content_id'])
      .and_return(pages)

    allow(LegacyTaxonomy::Client::SearchApi)
      .to receive(:content_tagged_to_topic)
      .with(taxon['base_path'])
      .and_return([])
  end

  def basic_taxon
    {
      'title' => 'foo',
      'description' => 'bar',
      'content_id' => 'foobar',
      'base_path' => '/path'
    }
  end

  def subtaxon
    {
      'title' => 'foo',
      'description' => 'bar',
      'content_id' => 'sub_taxon',
      'base_path' => '/subpath'
    }
  end

  def content_groups
    [
      {
        'name' => 'groupo_uno',
        'contents' => [
          '/path-of-group-contents'
        ]
      }
    ]
  end

  def root_browse_page_content_id
    "foo-bar-baz"
  end
end
