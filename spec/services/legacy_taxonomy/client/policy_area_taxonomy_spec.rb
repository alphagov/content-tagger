require 'rails_helper'

RSpec.describe LegacyTaxonomy::PolicyAreaTaxonomy do
  describe "#to_taxonomy_branch" do
    let(:result) do
      described_class.new('/foo').to_taxonomy_branch
    end

    before :each do
      stub_publishing_api_top_level_topic
    end

    context 'there is only one root, no children' do
      before do
        stub_publishing_api_top_level_topic
        stub_policy_areas([])
      end

      it 'returns the root browse taxon' do
        expect(result.title).to eq 'Policy Areas'
        expect(result.internal_name).to eq 'Policy Areas [PA]'
        expect(result.base_path).to eq '/foo/government/topics'
        expect(result.child_taxons).to be_empty
      end
    end

    context 'there is a child taxon' do
      before do
        stub_policy_areas([example_policy_area])
        stub_legacy_content_id(example_policy_area, ['id'])
        stub_documents(example_policy_area, [])
      end

      it 'returns the child taxon' do
        child_taxon = result.child_taxons.first
        expect(child_taxon.title).to eq(example_policy_area['title'])
        expect(child_taxon.internal_name).to eq("#{example_policy_area['title']} [PA]")
        expect(child_taxon.description).to eq(example_policy_area['description'])
        expect(child_taxon.path_slug).to eq(example_policy_area['link'])
        expect(child_taxon.path_prefix).to eq('/foo')
        expect(child_taxon.legacy_content_id).to eq(['id'])
        expect(child_taxon.tagged_pages).to eq([])
      end
    end

    context 'there are tagged pages' do
      before do
        stub_policy_areas([example_policy_area])
        stub_legacy_content_id(example_policy_area, ['id'])
        stub_documents(example_policy_area, [example_attached_document])
      end

      it 'returns the child taxon' do
        child_taxon = result.child_taxons.first
        expect(child_taxon.tagged_pages).to eq([example_attached_document])
      end
    end

    ####################
    #  HELPER METHODS  #
    ####################

    def stub_publishing_api_top_level_topic
      allow(LegacyTaxonomy::Client::PublishingApi)
        .to receive(:content_id_for_base_path)
        .with('/government/topics')
        .and_return root_browse_page_content_id
    end

    def stub_policy_areas(list)
      allow(LegacyTaxonomy::Client::SearchApi)
          .to receive(:policy_areas)
          .and_return list
    end

    def stub_legacy_content_id(policy_area, content_id)
      allow(LegacyTaxonomy::Client::PublishingApi)
          .to receive(:content_id_for_base_path)
                  .with(policy_area["link"])
                  .and_return content_id
    end

    def stub_documents(policy_area, list)
      allow(LegacyTaxonomy::Client::SearchApi)
          .to receive(:content_tagged_to_policy_area)
                  .with(policy_area["slug"])
                  .and_return list
    end

    def root_browse_page_content_id
      "foo-bar-baz"
    end

    def example_policy_area
      { "description" => "Public health is about helping people to stay healthy.",
        "format" => "topic",
        "link" => "/government/topics/public-health",
        "slug" => "public-health",
        "title" => "Public health",
        "index" => "government",
        "es_score" => nil,
        "_id" => "/government/topics/public-health",
        "elasticsearch_type" => "edition",
        "document_type" => "edition" }
    end

    def example_attached_document
      { "content_id" => "f4428540-a13d-45d2-877f-283bef8d96c5",
        "link" => "/government/news/sad-death-of-mhra-non-executive-director-professor-barrington-furr" }
    end
  end
end
