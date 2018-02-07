require 'rails_helper'
require 'gds_api/test_helpers/content_store'

RSpec.describe Taxonomy::TaxonTreeExport do
  include PublishingApiHelper
  include ContentItemHelper

  let(:taxon_id) { "123456" }

  describe "#initialize" do
    subject { described_class.new(taxon_id) }

    it "class should instantiate with 1 argument" do
      expect(subject).to be_an_instance_of(TaxonTreeExport)
      expect(subject.taxon_content_id).to eq(taxon_id)
    end
  end

  describe "#expanded_taxon" do
    subject { described_class.new(taxon_id) }

    it "should return a ExpandedTaxonomy instance" do
      publishing_api_has_item(content_id: taxon_id, title: 'content')
      expect(subject.expanded_taxon).to be_an_instance_of(ExpandedTaxonomy)
    end
  end
end
