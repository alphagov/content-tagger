require 'rails_helper'

RSpec.describe Taxonomy::BuildTaxonPayload do
  let(:taxon) do
    instance_double(
      Taxon,
      title: 'My Title',
      base_path: "/taxons/my-taxon",
      description: "This is a taxon.",
      internal_name: "Internal title",
      notes_for_editors: "Use this taxon wisely."
    )
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
