require "rails_helper"

RSpec.describe AlphaTaxonomy::TaxonPresenter do
  describe "#new" do
    it "exposes title and slug for the taxon" do
      presenter = AlphaTaxonomy::TaxonPresenter.new(title: "Foobar Taxon")
      expect(presenter.title).to eq "Foobar Taxon"
      expect(presenter.slug).to eq "foobar-taxon"
    end

    context "given a blank title" do
      it "raises an error" do
        expect { AlphaTaxonomy::TaxonPresenter.new(title: nil) }.to raise_error(ArgumentError)
        expect { AlphaTaxonomy::TaxonPresenter.new(title: '') }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#present" do
    it "presents a taxon payload" do
      allow(DateTime).to receive(:current).and_return(OpenStruct.new(iso8601: DateTime.new(0).iso8601))
      expect(AlphaTaxonomy::TaxonPresenter.new(title: "Foobar Taxon").present).to eq(
        base_path: "/alpha-taxonomy/foobar-taxon",
        format: "taxon",
        locale: "en",
        public_updated_at: DateTime.new(0).iso8601,
        publishing_app: "collections-publisher",
        rendering_app: "collections",
        routes: [path: "/alpha-taxonomy/foobar-taxon", type: "exact"],
        title: "Foobar Taxon",
      )
    end
  end

  describe "#base_path" do
    it "returns the base path derived from the title" do
      expect(AlphaTaxonomy::TaxonPresenter.new(title: "Foobar Taxon").base_path).to eq(
        "/alpha-taxonomy/foobar-taxon"
      )
    end
  end
end
