require 'rails_helper'

RSpec.describe ContentIdValidator do
  it 'validates a missing content id' do
    record = double(content_id: nil, errors: { content_id: [] })
    described_class.new.validate(record)

    expect(record.errors[:content_id]).to include(/we could not find this url/i)
  end

  it 'does not add validation errors when content id exists' do
    record = double(content_id: 'a-content-ID', errors: {})
    described_class.new.validate(record)

    expect(record.errors).to be_empty
  end
end
