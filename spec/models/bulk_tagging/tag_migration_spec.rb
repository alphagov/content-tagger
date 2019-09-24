require "rails_helper"

module BulkTagging
  RSpec.describe TagMigration do
    describe "#state" do
      context "valid states" do
        it "can be in an imported state" do
          expect(build(:tag_migration, state: :imported)).to be_valid
        end

        it "can be in a ready to import state" do
          expect(build(:tag_migration, state: :ready_to_import)).to be_valid
        end

        it "can be in an error state" do
          expect(build(:tag_migration, state: :errored)).to be_valid
        end
      end
    end

    describe "#mark_as_deleted" do
      it "updates the deleted_at date" do
        tag_migration = build(:tag_migration)
        expect(tag_migration.deleted_at).to be_nil

        tag_migration.mark_as_deleted
        expect(tag_migration.deleted_at).to_not be_nil
      end
    end
  end
end
