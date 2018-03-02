require 'rails_helper'

RSpec.describe Taxonomy::EditPage do
  describe "#show_visibilty_checkbox?" do
    it "is true when Taxon is a level one taxon" do
      taxon = instance_double(Taxon, parent: GovukTaxonomy::ROOT_CONTENT_ID)
      result = Taxonomy::EditPage.new(taxon).show_visibilty_checkbox?

      expect(result).to be true
    end

    it "is false when Taxon is not level one taxon" do
      taxon = instance_double(Taxon, parent: double)
      result = Taxonomy::EditPage.new(taxon).show_visibilty_checkbox?

      expect(result).to be false
    end

  end
end
