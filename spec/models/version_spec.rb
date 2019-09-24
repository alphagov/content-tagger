require "rails_helper"

RSpec.describe Version, ".history" do
  it "returns the the version history in descending order" do
    content_id = SecureRandom.uuid

    Version.create(content_id: content_id)
    Version.create(content_id: content_id)

    expect(Version.history(content_id).pluck(:content_id, :number))
      .to eq([[content_id, 2], [content_id, 1]])
  end
end

RSpec.describe Version, ".latest_version" do
  it "returns the highest numbered version" do
    content_id = SecureRandom.uuid

    Version.create(content_id: content_id)
    Version.create(content_id: content_id)

    expect(Version.latest_version(content_id).number).to eq(2)
  end
end

RSpec.describe Version, "incrementing version number" do
  it "creates Version #1 if a Version does not exist yet" do
    content_id = SecureRandom.uuid

    expect(Version.where(content_id: content_id)).to be_empty

    Version.create(content_id: content_id)

    expect(Version.where(content_id: content_id).count).to eq(1)
    expect(Version.last.number).to eq(1)
  end

  it "increments the version number" do
    Version.create(content_id: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
    Version.create(content_id: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
    Version.create(content_id: "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz")
    Version.create(content_id: "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz")
    Version.create(content_id: "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz")

    expect(Version.pluck(:content_id, :number))
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
