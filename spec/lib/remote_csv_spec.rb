require "rails_helper"

RSpec.describe RemoteCsv do
  include RemoteCsvHelper

  subject { described_class.new(RemoteCsvHelper::CSV_URL) }

  describe "#to_enum" do
    it "yields for each row of the CSV" do
      stub_remote_csv
      result = subject.to_enum.map do |row|
        RemoteCsvHelper::CSV_HEADERS.map { |header| row[header] }
      end
      expect(result).to eql RemoteCsvHelper::CSV_ROWS
    end
  end
end
