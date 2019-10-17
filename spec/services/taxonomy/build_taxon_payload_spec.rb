require "rails_helper"

RSpec.describe Taxonomy::BuildTaxonPayload do
  let(:taxon) do
    instance_double(
      Taxon,
      title: "My Title",
      base_path: "/taxons/my-taxon",
      description: "This is a taxon.",
      internal_name: "Internal title",
      notes_for_editors: "Use this taxon wisely.",
      visible_to_departmental_editors: true,
      phase: "live",
    )
  end

  describe ".call" do
    let(:payload) { described_class.call(taxon: taxon) }

    it "generates a valid payload" do
      expect(payload).to be_valid_against_schema("taxon")
    end

    it "assigns the expected rendering app" do
      expect(payload[:publishing_app]).to eq("content-tagger")
    end

    it "sets locale to 'en' default" do
      expect(payload[:locale]).to eq("en")
    end

    context "non-'en' locale" do
      let(:payload) { described_class.call(taxon: taxon, locale: "fr") }

      it "sets locale to non-'en' locale" do
        expect(payload[:locale]).to eq("fr")
      end

      it "appends non-'en' locale to the base_path" do
        expect(payload[:base_path]).to eq("#{taxon.base_path}.fr")
      end

      it "appends non-'en' locale to routes path" do
        expect(payload[:routes][0][:path]).to eq("#{taxon.base_path}.fr")
      end

      it "sets description to nil" do
        expect(payload[:description]).to be nil
      end
    end
  end
end
