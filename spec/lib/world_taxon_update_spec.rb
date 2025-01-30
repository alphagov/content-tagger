RSpec.describe "world taxon update", type: :task do
  include RakeTaskHelper

  describe "add_country_name_to_title" do
    it "calls add_country_names on WorldTaxonUpdateHelper" do
      helper = double
      allow(WorldTaxonUpdateHelper).to receive(:new).and_return(helper)

      expect(helper).to receive(:add_country_names)

      FakeFS do
        FileUtils.mkdir_p("tmp")
        expect { rake("worldwide:add_country_name_to_title", "tmp/taxon_update_log.txt") }
          .not_to raise_error
        expect(open("tmp/taxon_update_log.txt").read.length).to be 0
      end
    end
  end

  describe "remove_country_name_from_title" do
    it "calls remove_country_names on WorldTaxonUpdateHelper" do
      helper = double
      allow(WorldTaxonUpdateHelper).to receive(:new).and_return(helper)

      expect(helper).to receive(:remove_country_names)

      FakeFS do
        FileUtils.mkdir_p("tmp")
        expect { rake("worldwide:remove_country_name_from_title", "tmp/taxon_update_log.txt") }
          .not_to raise_error
        expect(open("tmp/taxon_update_log.txt").read.length).to be 0
      end
    end
  end
end
