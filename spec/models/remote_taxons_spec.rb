require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'

RSpec.describe RemoteTaxons do
  include ContentItemHelper
  include PublishingApiHelper
  include GdsApi::TestHelpers::PublishingApiV2

  describe '#search' do
    it 'fetches taxons from the publishing api with pagination' do
      taxon_1 = { title: "foo" }
      taxon_2 = { title: "bar" }
      taxon_3 = { title: "aha" }
      publishing_api_has_taxons(
        [taxon_1, taxon_2, taxon_3],
        page: 2,
        per_page: 2
      )

      result = described_class.new.search(page: 2, per_page: 2)

      expect(result).to be_a(TaxonSearchResults)
      expect(result.taxons.length).to eq(1)
      taxon = result.taxons.first
      expect(taxon.title).to eq('aha')
    end

    it 'is possible to search with a query string' do
      taxon_1 = { title: "foo" }
      publishing_api_has_taxons(
        [taxon_1],
        page: 1,
        per_page: 1,
        q: 'foo'
      )
      result = described_class.new.search(
        page: 1,
        per_page: 1,
        query: 'foo'
      )

      expect(result.taxons.length).to eq(1)
    end
  end

  describe '#parents_for_taxon' do
    let(:taxon_id_1) { SecureRandom.uuid }
    let(:taxon_id_2) { SecureRandom.uuid }
    let(:taxon_id_3) { SecureRandom.uuid }
    let(:taxon) do
      instance_double(Taxon, parent_taxons: [taxon_id_1, taxon_id_2])
    end

    it 'returns the parent taxons for a given taxon' do
      taxon_1 = content_item_with_details(
        "foo",
        other_fields: {
          base_path: "/foo",
          content_id: taxon_id_1
        }
      )
      taxon_2 = content_item_with_details(
        "bar",
        other_fields: {
          base_path: "/bar",
          content_id: taxon_id_2
        }
      )
      taxon_3 = content_item_with_details(
        "bar",
        other_fields: {
          base_path: "/bar",
          content_id: taxon_id_3
        }
      )
      publishing_api_has_item(taxon_1)
      publishing_api_has_links(content_id: taxon_id_1, links: {})
      publishing_api_has_item(taxon_2)
      publishing_api_has_links(content_id: taxon_id_2, links: {})
      publishing_api_has_item(taxon_3)
      publishing_api_has_links(content_id: taxon_id_3, links: {})

      result = described_class.new.parents_for_taxon(taxon)

      expect(result.count).to eq(2)
      expect(result).to include(taxon_with_attributes(taxon_1))
      expect(result).to include(taxon_with_attributes(taxon_2))
    end
  end

  describe '#childs_for_taxon' do
    it 'returns the parent taxons for a given taxon' do
      parent_taxon = build(:taxon)
      child_taxon_1 = build(:taxon, parent_taxons: [parent_taxon.content_id], content_id: 'child-taxon-1')
      child_taxon_2 = build(:taxon, parent_taxons: [parent_taxon.content_id], content_id: 'child-taxon-2')

      publishing_api_has_taxons([parent_taxon, child_taxon_1, child_taxon_2])

      result = described_class.new.childs_for_taxon(parent_taxon)

      expect(result.count).to eq(2)
      expect(result.first.content_id).to eql(child_taxon_1.content_id)
      expect(result.last.content_id).to eql(child_taxon_2.content_id)
    end
  end
end
