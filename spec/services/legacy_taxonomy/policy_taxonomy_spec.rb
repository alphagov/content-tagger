require 'rails_helper'

RSpec.describe LegacyTaxonomy::PolicyTaxonomy do
  describe "#to_taxonomy_branch" do
    let(:result) do
      described_class.new('/foo').to_taxonomy_branch
    end

    before :each do
      stub_publishing_api_top_level_topic
    end

    context 'there is only one root, no children' do
      before do
        stub_policy_areas([])
      end

      it 'returns the root browse taxon' do
        expect(result.title).to eq 'Imported Policy Areas + Policies'
        expect(result.internal_name).to eq 'Imported Policy Areas + Policies [P]'
        expect(result.base_path).to eq '/foo/government/topics'
        expect(result.child_taxons).to be_empty
      end
    end

    context 'there is a child taxon' do
      before do
        stub_policy_areas([example_policy_area])
        stub_legacy_content_id(example_policy_area, ['id'])
        stub_policies_from_whitehall(example_policy_area, [])
      end

      it 'returns the child taxon' do
        child_taxon = result.child_taxons.first
        expect(child_taxon.title).to eq(example_policy_area['title'])
        expect(child_taxon.internal_name).to eq("#{example_policy_area['title']} [P]")
        expect(child_taxon.description).to eq(example_policy_area['description'])
        expect(child_taxon.path_slug).to eq(example_policy_area['link'])
        expect(child_taxon.path_prefix).to eq('/foo')
        expect(child_taxon.legacy_content_id).to eq(['id'])
        expect(child_taxon.tagged_pages).to eq([])
      end
    end

    context 'there is a policy related to the policy area' do
      before do
        stub_policy_areas([example_policy_area])
        stub_legacy_content_id(example_policy_area, ['id'])
        stub_policies_from_whitehall(example_policy_area, [example_policy["content_id"]])
        publishing_api_has_item(example_policy)
        stub_documents_tagged_to_policy("library-services", [])
      end

      it 'returns the policy as child taxon' do
        parent_taxon = result.child_taxons.first
        child_taxon = result.child_taxons.first.child_taxons.first

        expect(child_taxon.title).to eq(example_policy['title'])
        expect(child_taxon.internal_name).to eq("#{example_policy['title']} [P]")
        expect(child_taxon.description).to eq(example_policy['description'])
        expect(child_taxon.path_prefix).to eq('/foo')
        expect(child_taxon.legacy_content_id).to eq(example_policy['content_id'])

        expected_path_slug = "#{parent_taxon.path_slug}/library-services"
        expect(child_taxon.path_slug).to eq(expected_path_slug)
      end

      context 'there are no tagged pages' do
        it 'does not return any tagged pages' do
          child_taxon = result.child_taxons.first.child_taxons.first
          expect(child_taxon.tagged_pages).to eq([])
        end
      end

      context 'there are tagged pages' do
        before do
          stub_documents_tagged_to_policy("library-services", [example_attached_document])
        end

        it 'returns the tagged pages' do
          child_taxon = result.child_taxons.first.child_taxons.first
          expect(child_taxon.tagged_pages).to eq([example_attached_document])
        end
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
        .with(policy_area['link'])
        .and_return content_id
    end

    def stub_policies_from_whitehall(policy_area, list)
      allow(LegacyTaxonomy::Client::Whitehall)
        .to receive(:policies_for_policy_area)
        .with(policy_area['slug'])
        .and_return list
    end

    def stub_documents_tagged_to_policy(policy_slug, list)
      allow(LegacyTaxonomy::Client::SearchApi)
        .to receive(:content_tagged_to_policy)
        .with(policy_slug)
        .and_return list
    end

    def root_browse_page_content_id
      'foo-bar-baz'
    end

    def example_policy_area
      {
        "format" => "topic",
        "title" => "Arts and Culture",
        "slug" => "arts-culture",
        "description" => "Arts and Culture enrich the soul.",
        "link" => "/government/topics/arts-culture",
        "index" => "government",
        "es_score" => nil,
        "_id" => "/government/topics/arts-culture",
        "elasticsearch_type" => "edition",
        "document_type" => "edition",
      }
    end

    def example_policy
      {
        "content_id" => "aaaa-bbbb",
        "title" => "Library services",
        "description" => "All things related to borrowing books",
        "base_path" => "/government/policies/library-services",
      }
    end

    def example_attached_document
      {
        "content_id" => "f4428540-a13d-45d2-877f-283bef8d96c5",
        "link" => "/government/news/sad-death-of-mhra-non-executive-director-professor-barrington-furr"
      }
    end
  end
end
