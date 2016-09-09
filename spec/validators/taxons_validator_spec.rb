require 'rails_helper'

RSpec.describe TaxonsValidator do
  include PublishingApiHelper

  before do
    taxon = { title: "A taxon", content_id: 'taxon1-content-id' }

    publishing_api_has_taxons([taxon])
  end

  it 'validates unknown taxons' do
    record = double(taxons: ['an-unknown-taxon'], errors: { taxons: [] })
    described_class.new.validate(record)

    expect(record.errors[:taxons]).to include(/invalid taxons found/i)
  end

  it 'does not add validation errors when we have correct taxons' do
    record = double(taxons: ['taxon1-content-id'], errors: {})
    described_class.new.validate(record)

    expect(record.errors).to be_empty
  end
end
