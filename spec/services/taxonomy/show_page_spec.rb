require "rails_helper"

RSpec.describe Taxonomy::ShowPage do
  describe "#publication_state_name" do
    it "shows when a taxon is published" do
      taxon = build(:taxon)
      show_page = Taxonomy::ShowPage.new(taxon)
      taxon.state_history = {
        "1" => "superseded",
        "2" => "published",
      }

      expect(show_page.publication_state_name).to eq("published")
    end

    it "shows when a taxon is in draft" do
      taxon = build(:draft_taxon)
      taxon.state_history = {
        "1" => "draft",
      }
      show_page = Taxonomy::ShowPage.new(taxon)

      expect(show_page.publication_state_name).to eq("draft")
    end

    it "shows when a draft taxon has been previously published" do
      taxon = build(:previously_published_draft_taxon)
      show_page = Taxonomy::ShowPage.new(taxon)

      expect(show_page.publication_state_name).to eq("published_with_new_draft")
    end
  end
end
