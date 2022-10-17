module BulkTagging
  RSpec.describe AggregatedTagMappingPresenter do
    let!(:tag_mappings) { [create(:tag_mapping), create(:tag_mapping)] }
    let(:aggregated_tag_mapping) { TaggingSpreadsheet.first.aggregated_tag_mappings.first }
    let(:presenter) { described_class.new(aggregated_tag_mapping) }

    describe "#errored?" do
      it 'should return true when any tag mapping state is "errored"' do
        tag_mappings.first.update!(state: "errored")

        expect(presenter.errored?).to be_truthy
      end

      it 'should return false when none of the tag mappings state is not "errored"' do
        tag_mappings.first.update!(state: "tagged")

        expect(presenter.errored?).to be_falsey
      end
    end
  end
end
