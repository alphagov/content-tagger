RSpec.describe Taxonomy::EditPage do
  describe "#show_visibilty_checkbox?" do
    it "is true when Taxon is a level one taxon" do
      taxon = instance_double(Taxon, parent_content_id: GovukTaxonomy::ROOT_CONTENT_ID)
      result = Taxonomy::EditPage.new(taxon).show_visibilty_checkbox?

      expect(result).to be true
    end

    it "is false when Taxon is not level one taxon" do
      taxon = instance_double(Taxon, parent_content_id: double)
      result = Taxonomy::EditPage.new(taxon).show_visibilty_checkbox?

      expect(result).to be false
    end
  end

  describe "#show_url_override_input_field?" do
    it "returns true when the url_override_permission is true" do
      taxon = instance_double(Taxon)
      result = Taxonomy::EditPage.new(taxon, true).show_url_override_input_field?

      expect(result).to be true
    end

    it "returns false when the url_override_permission is false" do
      taxon = instance_double(Taxon)
      url_override_permission = false
      page = Taxonomy::EditPage.new(taxon, url_override_permission)
      result = page.show_url_override_input_field?

      expect(result).to be false
    end
  end

  describe "#show_url_override?" do
    it "returns false if the user has url_override_permission" do
      taxon = instance_double(Taxon, url_override: "")
      url_override_permission = true
      page = Taxonomy::EditPage.new(taxon, url_override_permission)
      result = page.show_url_override?

      expect(result).to be false
    end

    it "returns false if the user has no url_override_permission and url_override is empty" do
      taxon = instance_double(Taxon, url_override: "")
      url_override_permission = false
      page = Taxonomy::EditPage.new(taxon, url_override_permission)
      result = page.show_url_override?

      expect(result).to be false
    end

    it "returns true if user has no url_override_permission and the url_override is present" do
      taxon = instance_double(Taxon, url_override: "/foo")
      url_override_permission = false
      page = Taxonomy::EditPage.new(taxon, url_override_permission)
      result = page.show_url_override?

      expect(result).to be true
    end
  end
end
