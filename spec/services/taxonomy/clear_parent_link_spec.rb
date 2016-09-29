require 'rails_helper'

RSpec.describe Taxonomy::ClearParentLink do
  it 're-publishes the parent link with an empty list of links' do
    expect(PublishLinks).to receive(:call).with(
      links_update: instance_of(TaxonParentLinksUpdate)
    )

    described_class.call('a-content-id')
  end
end
