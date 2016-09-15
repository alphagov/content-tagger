require 'rails_helper'

RSpec.describe TaggingSpreadsheet do
  describe '#state' do
    context 'valid states' do
      it 'can be in an imported state' do
        expect(build(:tagging_spreadsheet, state: :imported)).to be_valid
      end

      it 'can be in a ready to import state' do
        expect(build(:tagging_spreadsheet, state: :ready_to_import)).to be_valid
      end

      it 'can be in an error state' do
        expect(build(:tagging_spreadsheet, state: :errored)).to be_valid
      end

      it 'can be in an uploaded state' do
        expect(build(:tagging_spreadsheet, state: :uploaded)).to be_valid
      end
    end
  end

  describe '#mark_as_deleted' do
    it 'updates the deleted_at date' do
      tagging_spreadsheet = build(:tagging_spreadsheet)
      expect(tagging_spreadsheet.deleted_at).to be_nil

      tagging_spreadsheet.mark_as_deleted
      expect(tagging_spreadsheet.deleted_at).to_not be_nil
    end
  end
end
