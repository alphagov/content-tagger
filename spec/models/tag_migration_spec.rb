require 'rails_helper'

RSpec.describe TagMigration do
  describe '#mark_as_deleted' do
    it 'updates the deleted_at date' do
      tag_migration = build(:tag_migration)
      expect(tag_migration.deleted_at).to be_nil

      tag_migration.mark_as_deleted
      expect(tag_migration.deleted_at).to_not be_nil
    end
  end
end
