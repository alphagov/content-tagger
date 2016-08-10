require 'rails_helper'

RSpec.describe TaggingSpreadsheet do
  describe '#mark_as_deleted' do
    it 'updates the deleted_at date' do
      tagging_spreadsheet = build(:tagging_spreadsheet)
      expect(tagging_spreadsheet.deleted_at).to be_nil

      tagging_spreadsheet.mark_as_deleted
      expect(tagging_spreadsheet.deleted_at).to_not be_nil
    end
  end
end
