require 'rails_helper'

RSpec.describe Taxonomy::TaxonPayloadBuilder do
  let(:taxon) do
    instance_double(Taxon, title: 'My Title', base_path: "/taxons/my-taxon")
  end
  let(:builder) { described_class.new(taxon) }

  describe "#build" do
    let(:payload) { builder.build }

    it "generates a valid payload" do
      expect(payload).to be_valid_against_schema('taxon')
    end

    it 'assigns the expected rendering app' do
      expect(payload[:publishing_app]).to eq('content-tagger')
    end
  end
end
