RSpec.describe CircularDependencyValidator do
  it "errors if the parent contain the record" do
    record = build(
      :taxon,
      content_id: "foo",
      parent_content_id: "foo",
    )
    described_class.new.validate(record)

    expect(record.errors[:parent_content_id])
      .to include(/you can't set a taxon as the parent of itself/i)
  end

  it "does nothing if the parent don't contain the record" do
    record = build(
      :taxon,
      content_id: "foo",
      parent_content_id: "bar",
    )
    described_class.new.validate(record)

    expect(record.errors[:parent_content_id]).to be_empty
  end
end
