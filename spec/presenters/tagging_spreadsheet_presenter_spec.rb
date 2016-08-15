require 'rails_helper'

RSpec.describe TaggingSpreadsheetPresenter do
  let(:tagging_spreadsheet) { TaggingSpreadsheet.new }
  let(:presenter) { described_class.new(tagging_spreadsheet) }

  describe 'label_type' do
    it 'returns a label css class indicting an error for the errored state' do
      tagging_spreadsheet.state = 'errored'

      expect(presenter.label_type).to eq('label-danger')
    end

    it 'returns a label css class indicting a success for the imported state' do
      tagging_spreadsheet.state = 'imported'

      expect(presenter.label_type).to eq('label-success')
    end

    it 'returns a label css class indicting a warning for the ready_to_import state' do
      tagging_spreadsheet.state = 'ready_to_import'

      expect(presenter.label_type).to eq('label-warning')
    end

    it 'returns a label css class indicting a warning for the uploaded state' do
      tagging_spreadsheet.state = 'uploaded'

      expect(presenter.label_type).to eq('label-warning')
    end
  end

  describe '#state_title' do
    it 'humanizes the state' do
      tagging_spreadsheet.state = 'errored'

      expect(presenter.state_title).to eq('Errored')
    end
  end

  describe '#data_attributes' do
    it 'returns the tooltip data attributes with the error message for the errored state' do
      tagging_spreadsheet.state = 'errored'
      tagging_spreadsheet.error_message = 'an error message'

      expect(presenter.data_attributes).to include('toggle': 'tooltip')
      expect(presenter.data_attributes).to include(
        'original-title': tagging_spreadsheet.error_message
      )
    end

    it 'does not return data attributes for the imported state' do
      tagging_spreadsheet.state = 'imported'

      expect(presenter.data_attributes).to be_empty
    end

    it 'does not return data attributes for the ready_to_import state' do
      tagging_spreadsheet.state = 'ready_to_import'

      expect(presenter.data_attributes).to be_empty
    end

    it 'does not return data attributes for the uploaded state' do
      tagging_spreadsheet.state = 'uploaded'

      expect(presenter.data_attributes).to be_empty
    end
  end
end
