require 'rails_helper'

RSpec.describe TagMigrationPresenter do
  let(:tag_migration) { TagMigration.new }
  let(:presenter) { described_class.new(tag_migration) }

  describe 'label_type' do
    it 'returns a label css class indicting a success for the imported state' do
      tag_migration.state = 'imported'

      expect(presenter.label_type).to eq('label-success')
    end

    it 'returns a label css class indicting a warning for the ready_to_import state' do
      tag_migration.state = 'ready_to_import'

      expect(presenter.label_type).to eq('label-warning')
    end
  end

  describe '#state_title' do
    it 'humanizes the state' do
      tag_migration.state = 'imported'

      expect(presenter.state_title).to eq('Imported')
    end
  end
end
