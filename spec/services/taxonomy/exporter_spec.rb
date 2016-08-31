require 'rails_helper'

RSpec.describe Taxonomy::Exporter do
  before do
    linkables = [
      { "title" => "Taxon 1", "base_path" => "/taxon-1", "content_id" => "taxon-1" },
      { "title" => "Taxon 2", "base_path" => "/taxon-2", "content_id" => "taxon-2" },
      { "title" => "Taxon 3", "base_path" => "/taxon-3", "content_id" => "taxon-3" },
    ]
    publishing_api_has_linkables(linkables, document_type: 'taxon')
  end

  it 'has a filename' do
    exporter = described_class.new([])
    time = Time.parse('2015-01-10 22:15:24')
    expect(Time).to receive(:current).and_return(time)

    expect(exporter.filename).to eq('content-id-lookup-20150110221524.csv')
  end

  it 'includes only the expected taxons in the data and the headers' do
    exporter = described_class.new(['taxon-1', 'taxon-3'])
    csv_data = CSV.parse(exporter.data)

    expect(csv_data.count).to eq(3)

    expect(csv_data[0]).to eq(["Title", "Taxon Content ID", "Link Type"])
    expect(csv_data[1]).to eq(["Taxon 1", "taxon-1", "taxons"])
    expect(csv_data[2]).to eq(["Taxon 3", "taxon-3", "taxons"])

    expect(exporter.data).to_not include('Taxon 2')
    expect(exporter.data).to_not include('taxon-2')
  end

  it 'returns just the headers with no content ids' do
    exporter = described_class.new(nil)
    csv_data = CSV.parse(exporter.data)

    expect(csv_data.count).to eq(1)
    expect(csv_data[0]).to eq(["Title", "Taxon Content ID", "Link Type"])
  end
end
