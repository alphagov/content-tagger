require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'

RSpec.describe TaxonForm do
  include GdsApi::TestHelpers::PublishingApiV2

  context 'validations' do
    it 'is not valid without a title' do
      taxon_form = described_class.new
      expect(taxon_form).to_not be_valid
      expect(taxon_form.errors.keys).to include(:title)
    end
  end

  it 'generates unique base paths for the same title' do
    taxon_form_1 = described_class.new(title: 'A Title')
    taxon_form_2 = described_class.new(title: 'A Title')

    expect(taxon_form_1.base_path).to_not eq(taxon_form_2.base_path)
  end
end
