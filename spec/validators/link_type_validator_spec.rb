require "rails_helper"

RSpec.describe LinkTypeValidator do
  it "validates incorrect link types" do
    record = double(link_type: "organisations", errors: { link_type: [] })
    described_class.new.validate(record)

    expect(record.errors[:link_type]).to include(/invalid link types found/i)
  end

  it "does not add validation errors when we have expected link types" do
    record = double(link_type: "taxons", errors: {})
    described_class.new.validate(record)

    expect(record.errors).to be_empty
  end
end
