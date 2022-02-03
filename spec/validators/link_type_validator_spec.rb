require "rails_helper"

RSpec.describe LinkTypeValidator do
  it "validates incorrect link types" do
    record = build_stubbed(:tag_mapping, link_type: "organisations")
    described_class.new.validate(record)

    expect(record.errors[:link_type]).to include(/invalid link types found/i)
  end

  it "does not add validation errors when we have expected link types" do
    record = build_stubbed(:tag_mapping, link_type: "taxons")
    described_class.new.validate(record)

    expect(record.errors).to be_empty
  end
end
