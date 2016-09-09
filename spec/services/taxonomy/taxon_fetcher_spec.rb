require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'

RSpec.describe Taxonomy::TaxonFetcher do
  include GdsApi::TestHelpers::PublishingApiV2

  describe '#taxons' do
    it 'retrieves content items from publishing api and orders by title' do
      taxon_1 = { title: "foo", base_path: "/foo", content_id: SecureRandom.uuid }
      taxon_2 = { title: "bar", base_path: "/bar", content_id: SecureRandom.uuid }
      taxon_3 = { title: "aha", base_path: "/aha", content_id: SecureRandom.uuid }

      publishing_api_has_content([taxon_1, taxon_2, taxon_3], document_type: "taxon")

      result = described_class.new.taxons

      expect(result.first.title).to eq("aha")
      expect(result.last.title).to eq("foo")
    end
  end

  describe '#taxon_content_ids' do
    it 'returns the content ids of all taxons' do
      content_id_1 = SecureRandom.uuid
      content_id_2 = SecureRandom.uuid
      taxon_1 = { title: "foo", base_path: "/foo", content_id: content_id_1 }
      taxon_2 = { title: "bar", base_path: "/bar", content_id: content_id_2 }

      publishing_api_has_content([taxon_1, taxon_2], document_type: "taxon")

      result = described_class.new.taxon_content_ids

      expect(result).to include(content_id_1)
      expect(result).to include(content_id_2)
    end
  end

  describe '#parents_for_taxon' do
    let(:taxon_id_1) { SecureRandom.uuid }
    let(:taxon_id_2) { SecureRandom.uuid }
    let(:taxon) do
      instance_double(Taxon, parent_taxons: [taxon_id_1, taxon_id_2])
    end

    it 'returns the parent taxons for a given taxon' do
      taxon_1 = { title: "foo", base_path: "/foo", content_id: taxon_id_1 }
      taxon_2 = { title: "bar", base_path: "/bar", content_id: taxon_id_2 }
      taxon_3 = { title: "bar", base_path: "/bar", content_id: SecureRandom.uuid }

      publishing_api_has_content([taxon_1, taxon_2, taxon_3], document_type: "taxon")
      result = described_class.new.parents_for_taxon(taxon)

      expect(result.count).to eq(2)
      expect(result).to include(taxon_with_attributes(taxon_1))
      expect(result).to include(taxon_with_attributes(taxon_2))
    end
  end
end
