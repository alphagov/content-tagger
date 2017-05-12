require 'rails_helper'

RSpec.describe Taxonomy::EditPage do
  describe "#show_visibilty_checkbox?" do
    it "is true when Taxon is in Draft state and has no parent" do
      taxon = instance_double(Taxon, draft?: true, parent: nil)
      result = Taxonomy::EditPage.new(taxon).show_visibilty_checkbox?

      expect(result).to be true
    end

    it "is false when Taxon is in Draft state and has a parent" do
      taxon = instance_double(Taxon, draft?: true, parent: double)
      result = Taxonomy::EditPage.new(taxon).show_visibilty_checkbox?

      expect(result).to be false
    end

    it "is false when Taxon is not in Draft state and has a parent" do
      taxon = instance_double(Taxon, draft?: false, parent: double)
      result = Taxonomy::EditPage.new(taxon).show_visibilty_checkbox?

      expect(result).to be false
    end
  end
end
