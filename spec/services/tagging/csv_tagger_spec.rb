RSpec.describe Tagging::Tagger do
  subject { described_class }

  before do
    stub_request(:get, "http://example.com/sheet.csv").to_return(body: <<~CSV)
      content_id,taxon_id
      aaa,1
      bbb,2
      aaa,3
    CSV
  end

  it "adds tags from the spreadsheet" do
    expect(described_class).to receive(:add_tags).with("aaa", %w[1 3], :taxons)
    expect(described_class).to receive(:add_tags).with("bbb", %w[2], :taxons)

    Tagging::CsvTagger.do_tagging("http://example.com/sheet.csv")
  end

  it "returns groups in a block" do
    allow(described_class).to receive(:add_tags)
    log = []
    Tagging::CsvTagger.do_tagging("http://example.com/sheet.csv") do |b|
      log << b
    end
    expect(log).to match_array([{ content_id: "aaa", taxon_ids: %w[1 3] },
                                { content_id: "bbb", taxon_ids: %w[2] }])
  end
end
