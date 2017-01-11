require 'rails_helper'

RSpec.describe Taxonomy::PublishTaxon do
  let(:taxon) do
    Taxon.new(
      title: 'A Title',
      path_prefix: Theme::EDUCATION_THEME_BASE_PATH,
      path_slug: '/slug',
    )
  end
  let(:publish) { described_class.call(taxon: taxon) }

  describe '.call' do
    context 'with a valid taxon form' do
      it 'publishes the document via the publishing API' do
        expect(Services.publishing_api).to receive(:put_content)
        expect(Services.publishing_api).to receive(:publish)
        expect(Services.publishing_api).to receive(:patch_links)

        expect { publish }.to_not raise_error
      end
    end

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
        expect { publish }.to raise_error(
          Taxonomy::PublishTaxon::InvalidTaxonError,
          /there was a problem with your request/i
        )
      end
    end
  end
end
