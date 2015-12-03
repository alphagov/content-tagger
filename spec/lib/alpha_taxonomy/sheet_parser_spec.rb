require "rails_helper"

RSpec.describe AlphaTaxonomy::SheetParser do
  describe "#write_to(file)" do
    let(:test_output) { StringIO.new }

    it "parses and writes the required data to the file" do
      taxonomy_tsv_data = [
        "mapped to\t" + "link",
        "Foo-Taxon\t" + "the-foo-slug",
        "Bar (Br)| Baz (Bz)\t" + "the-bar-or-baz-slug",
        "n/a - not applicable\t" + "the-n/a-slug",
      ].join("\n")

      AlphaTaxonomy::SheetParser.new(taxonomy_tsv_data).write_to(test_output)

      test_output.rewind
      expect(test_output.read).to eq "Foo-Taxon\tthe-foo-slug\nBar (Br)|Baz (Bz)\tthe-bar-or-baz-slug\n"
    end

    it "falls over and dies if the expected columns aren't present" do
      taxonomy_tsv_data = [
        "some random column name\t" + "link",
        "Foo Taxon (Label)\t" + "the-foo-slug",
      ].join("\n")

      expect { AlphaTaxonomy::SheetParser.new(taxonomy_tsv_data).write_to(test_output) }.to raise_error(ArgumentError)
    end
  end
end
