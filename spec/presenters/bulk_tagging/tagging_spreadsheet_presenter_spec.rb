module BulkTagging
  RSpec.describe TaggingSpreadsheetPresenter do
    let(:tagging_spreadsheet) { TaggingSpreadsheet.new }
    let(:presenter) { described_class.new(tagging_spreadsheet) }

    describe "label_type" do
      it "returns a label css class indicting an error for the errored state" do
        tagging_spreadsheet.state = "errored"

        expect(presenter.label_type).to eq("label-danger")
      end

      it "returns a label css class indicting a success for the imported state" do
        tagging_spreadsheet.state = "imported"

        expect(presenter.label_type).to eq("label-success")
      end

      it "returns a label css class indicting a warning for the ready_to_import state" do
        tagging_spreadsheet.state = "ready_to_import"

        expect(presenter.label_type).to eq("label-warning")
      end

      it "returns a label css class indicting a warning for the uploaded state" do
        tagging_spreadsheet.state = "uploaded"

        expect(presenter.label_type).to eq("label-warning")
      end
    end

    describe "#state_title" do
      it "humanizes the state" do
        tagging_spreadsheet.state = "errored"

        expect(presenter.state_title).to eq("Errored")
      end
    end

    describe "errored?" do
      it 'returns true when state is "errored"' do
        tagging_spreadsheet.state = "errored"

        expect(presenter).to be_errored
      end

      it 'returns false when state is not "errored"' do
        tagging_spreadsheet.state = "tagged"

        expect(presenter).not_to be_errored
      end
    end
  end
end
