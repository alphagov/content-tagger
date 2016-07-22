require 'rails_helper'

RSpec.describe TaxonPresenter do
  describe "#payload" do
    let(:presenter) do
      TaxonPresenter.new(
        title: "My Title",
        base_path: "/taxons/my-taxon"
      )
    end
    let(:payload) { presenter.payload }

    it "generates a valid payload" do
      expect(payload).to be_valid_against_schema('taxon')
    end

    it 'assigns the expected rendering app' do
      expect(payload[:publishing_app]).to eq('content-tagger')
    end
  end
end
