require 'rails_helper'

RSpec.describe Tagging::Tagger do
  subject { described_class }
  before :each do
    stub_request(:get, 'http://example.com/sheet.csv').to_return(body: <<~CSV)
      content_id,taxon_id
      aaa,1
      bbb,2
      aaa,3
    CSV
  end
  it 'adds tags from the spreadsheet' do
    expect(Tagging::Tagger).to receive(:add_tags).with('aaa', %w[1 3])
    expect(Tagging::Tagger).to receive(:add_tags).with('bbb', ['2'])

    Tagging::CsvTagger.do_tagging('http://example.com/sheet.csv')
  end
  it 'returns groups in a block' do
    allow(Tagging::Tagger).to receive(:add_tags)
    log = []
    Tagging::CsvTagger.do_tagging('http://example.com/sheet.csv') do |b|
      log << b
    end
    expect(log).to match_array([{ content_id: 'aaa', taxon_ids: %w[1 3] },
                                { content_id: 'bbb', taxon_ids: ['2'] }])
  end
end
