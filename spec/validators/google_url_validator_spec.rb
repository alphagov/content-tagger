require "rails_helper"

RSpec.describe GoogleUrlValidator do
  include GoogleSheetHelper

  it "validates an incorrect host name" do
    record = double(url: "https://invalid.com", errors: { url: [] })
    GoogleUrlValidator.new.validate(record)

    expect(record.errors[:url]).to include(/is not a google docs url/i)
  end

  it "validates an incorrect path" do
    record = double(url: "https://docs.google.com/something/else", errors: { url: [] })
    GoogleUrlValidator.new.validate(record)

    expect(record.errors[:url]).to include(/does not have the expected public path/i)
  end

  it "validates missing param gid" do
    record = double(url: "https://docs.google.com/path?p=1&p=2", errors: { url: [] })
    GoogleUrlValidator.new.validate(record)

    expect(record.errors[:url]).to include(/is missing a google spreadsheet id/i)
  end

  it "validates missing param output" do
    record = double(url: "https://docs.google.com/path", errors: { url: [] })
    GoogleUrlValidator.new.validate(record)

    expect(record.errors[:url]).to include(/is missing the parameter output as csv/i)
  end

  it "validates incorrect param output" do
    record = double(url: "https://docs.google.com/path?output=pdf", errors: { url: [] })
    GoogleUrlValidator.new.validate(record)

    expect(record.errors[:url]).to include(/is missing the parameter output as csv/i)
  end

  it "does not add validation errors for a correct URL" do
    valid_url = google_sheet_url(key: "mykey", gid: "mygid")

    record = double(url: valid_url, errors: { url: [] })

    GoogleUrlValidator.new.validate(record)

    expect(record.errors[:url]).to be_empty
  end
end
