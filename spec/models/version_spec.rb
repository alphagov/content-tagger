RSpec.describe Version, ".history" do
  it "returns the the version history in descending order" do
    content_id = SecureRandom.uuid

    described_class.create!(content_id:)
    described_class.create!(content_id:)

    expect(described_class.history(content_id).pluck(:content_id, :number))
      .to eq([[content_id, 2], [content_id, 1]])
  end
end

RSpec.describe Version, ".latest_version" do
  it "returns the highest numbered version" do
    content_id = SecureRandom.uuid

    described_class.create!(content_id:)
    described_class.create!(content_id:)

    expect(described_class.latest_version(content_id).number).to eq(2)
  end
end

RSpec.describe Version, "incrementing version number" do
  it "creates Version #1 if a Version does not exist yet" do
    content_id = SecureRandom.uuid

    expect(described_class.where(content_id:)).to be_empty

    described_class.create!(content_id:)

    expect(described_class.where(content_id:).count).to eq(1)
    expect(described_class.last.number).to eq(1)
  end

  it "increments the version number" do
    described_class.create!(content_id: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
    described_class.create!(content_id: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
    described_class.create!(content_id: "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz")
    described_class.create!(content_id: "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz")
    described_class.create!(content_id: "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz")

    expect(described_class.pluck(:content_id, :number))
      .to eq(
        [
          ["aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", 1],
          ["aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", 2],
          ["zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz", 1],
          ["zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz", 2],
          ["zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz", 3],
        ],
      )
  end
end
