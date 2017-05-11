require 'rails_helper'

RSpec.describe CircularDependencyValidator do
  it "errors if the parent contain the record" do
    record = double(
      content_id: "foo",
      parent: "foo",
      errors: { parent: [] }
    )
    described_class.new.validate(record)

    expect(record.errors[:parent]).to include(/you can't set a taxon as the parent of itself/i)
  end

  it "does nothing if the parent don't contain the record" do
    record = double(
      content_id: "foo",
      parent: "bar",
      errors: { parent: [] }
    )
    described_class.new.validate(record)

    expect(record.errors[:parent]).to be_empty
  end
end
