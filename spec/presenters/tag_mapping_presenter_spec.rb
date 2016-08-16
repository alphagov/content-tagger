require 'rails_helper'

RSpec.describe TagMappingPresenter do
  let(:tag_mapping) { TagMapping.new }
  let(:presenter) { described_class.new(tag_mapping) }

  describe 'label_type' do
    it 'returns a label css class indicting an error for the errored state' do
      tag_mapping.state = 'errored'

      expect(presenter.label_type).to eq('label-danger')
    end

    it 'returns a label css class indicting a success for the taggedstate' do
      tag_mapping.state = 'tagged'

      expect(presenter.label_type).to eq('label-success')
    end

    it 'returns a label css class indicting a warning for the ready_to_tagstate' do
      tag_mapping.state = 'ready_to_tag'

      expect(presenter.label_type).to eq('label-warning')
    end
  end

  describe '#state_title' do
    it 'humanizes the state' do
      tag_mapping.state = 'errored'

      expect(presenter.state_title).to eq('Errored')
    end
  end

  describe '#data_attributes' do
    it 'returns the tooltip data attributes with the error message for the errored state' do
      tag_mapping.state = 'errored'
      tag_mapping.message = 'an error message'

      expect(presenter.data_attributes).to include('toggle': 'tooltip')
      expect(presenter.data_attributes).to include(
        'original-title': tag_mapping.message
      )
    end

    it 'does not return data attributes for the tagged state' do
      tag_mapping.state = 'tagged'

      expect(presenter.data_attributes).to be_empty
    end

    it 'does not return data attributes for the ready_to_tagstate' do
      tag_mapping.state = 'ready_to_tag'

      expect(presenter.data_attributes).to be_empty
    end
  end
end
