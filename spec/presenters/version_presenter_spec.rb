RSpec.describe VersionPresenter, "#changes" do
  it "returns a change hash for an attribute addition" do
    version = Version.create!(
      content_id: SecureRandom.uuid,
      object_changes: [
        ["+", "title", "Business"],
      ],
    )

    changes = described_class.new(version).changes

    expect(changes).to eq(
      [
        ["title", [nil, "Business"]],
      ],
    )
  end

  it "returns a change hash for an attribute change" do
    version = Version.create!(
      content_id: SecureRandom.uuid,
      object_changes: [
        ["~", "title", "Business", "Business tax"],
      ],
    )

    changes = described_class.new(version).changes

    expect(changes).to eq(
      [
        ["title", ["Business", "Business tax"]],
      ],
    )
  end

  it "returns a change hash for an attribute deletion" do
    version = Version.create!(
      content_id: SecureRandom.uuid,
      object_changes: [
        ["-", "title", "Business"],
      ],
    )

    changes = described_class.new(version).changes

    expect(changes).to eq(
      [
        ["title", ["Business", nil]],
      ],
    )
  end
end
