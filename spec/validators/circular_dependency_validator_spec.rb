require 'rails_helper'

RSpec.describe CircularDependencyValidator do
  it "errors if the parent_taxons contain the record" do
    record = double(
      content_id: "foo",
      parent_taxons: %w(bar foo baz),
      errors: { parent_taxons: [] }
    )
    described_class.new.validate(record)

    expect(record.errors[:parent_taxons]).to include(/you can't set a taxon as the parent of itself/i)
  end

  it "does nothing if the parent_taxons don't contain the record" do
    record = double(
      content_id: "foo",
      parent_taxons: %w(bar baz),
      errors: { parent_taxons: [] }
    )
    described_class.new.validate(record)

    expect(record.errors[:parent_taxons]).to be_empty
  end
end
