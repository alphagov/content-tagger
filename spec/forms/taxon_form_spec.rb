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

  describe '#create!' do
    let(:taxon_form) { described_class.new(title: 'A Title') }

    context 'with an unprocessable entity error from the API' do
      let(:error) do
        GdsApi::HTTPUnprocessableEntity.new(
          422,
          "An internal error message",
          'error' => { 'message' => 'Some backend error' }
        )
      end

      before do
        allow(Services.publishing_api).to receive(:put_content).and_raise(error)
      end

      it 'raises an error with a generic message and notifies Airbrake' do
        expect(Airbrake).to receive(:notify).with(error)
        expect { taxon_form.create! }.to raise_error(
          TaxonForm::InvalidTaxonError,
          /there was a problem with your request/i
        )
      end
    end
  end
end
