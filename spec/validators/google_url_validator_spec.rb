RSpec.describe GoogleUrlValidator do
  include GoogleSheetHelper

  it "validates an incorrect host name" do
    record = build_stubbed(:tagging_spreadsheet, url: "https://invalid.com")
    described_class.new.validate(record)

    expect(record.errors[:url]).to include(/is not a google docs url/i)
  end

  it "validates an incorrect path" do
    record = build_stubbed(:tagging_spreadsheet, url: "https://docs.google.com/something/else")
    described_class.new.validate(record)

    expect(record.errors[:url]).to include(/does not have the expected public path/i)
  end

  it "validates missing param gid" do
    record = build_stubbed(:tagging_spreadsheet, url: "https://docs.google.com/path?p=1&p=2")
    described_class.new.validate(record)

    expect(record.errors[:url]).to include(/is missing a google spreadsheet id/i)
  end

  it "validates missing param output" do
    record = build_stubbed(:tagging_spreadsheet, url: "https://docs.google.com/path")
    described_class.new.validate(record)

    expect(record.errors[:url]).to include(/is missing the parameter output as csv/i)
  end

  it "validates incorrect param output" do
    record = build_stubbed(:tagging_spreadsheet, url: "https://docs.google.com/path?output=pdf")
    described_class.new.validate(record)

    expect(record.errors[:url]).to include(/is missing the parameter output as csv/i)
  end

  it "does not add validation errors for a correct URL" do
    valid_url = google_sheet_url(key: "mykey", gid: "mygid")

    record = build_stubbed(:tagging_spreadsheet, url: valid_url)

    described_class.new.validate(record)

    expect(record.errors[:url]).to be_empty
  end
end
