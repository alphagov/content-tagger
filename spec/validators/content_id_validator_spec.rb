require "rails_helper"

RSpec.describe ContentIdValidator do
  let(:record) { build_stubbed(:tag_mapping) }

  it "validates a missing content id" do
    allow(record).to receive(:content_id).and_return nil

    described_class.new.validate(record)

    expect(record.errors[:content_id]).to include(/we could not find this url/i)
  end

  it "does not add validation errors when content id exists" do
    allow(record).to receive(:content_id).and_return "a-content-ID"

    described_class.new.validate(record)

    expect(record.errors).to be_empty
  end
end
