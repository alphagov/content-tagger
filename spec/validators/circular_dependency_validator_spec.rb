require 'rails_helper'

RSpec.describe CircularDependencyValidator do
  it "errors if the parent contain the record" do
    record = double(
      content_id: "foo",
      parent_content_id: "foo",
      errors: { parent_content_id: [] }
    )
    described_class.new.validate(record)

    expect(record.errors[:parent_content_id])
      .to include(/you can't set a taxon as the parent of itself/i)
  end

  it "does nothing if the parent don't contain the record" do
    record = double(
      content_id: "foo",
      parent_content_id: "bar",
      errors: { parent_content_id: [] }
    )
    described_class.new.validate(record)

    expect(record.errors[:parent_content_id]).to be_empty
  end
end
