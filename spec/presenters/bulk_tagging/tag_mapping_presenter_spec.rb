module BulkTagging
  RSpec.describe TagMappingPresenter do
    let(:tag_mapping) { TagMapping.new }
    let(:presenter) { described_class.new(tag_mapping) }

    describe "label_type" do
      it "returns a label css class indicting an error for the errored state" do
        tag_mapping.state = "errored"

        expect(presenter.label_type).to eq("label-danger")
      end

      it "returns a label css class indicting a success for the taggedstate" do
        tag_mapping.state = "tagged"

        expect(presenter.label_type).to eq("label-success")
      end

      it "returns a label css class indicting a warning for the ready_to_tagstate" do
        tag_mapping.state = "ready_to_tag"

        expect(presenter.label_type).to eq("label-default")
      end
    end

    describe "#state_title" do
      it "humanizes the state" do
        tag_mapping.state = "errored"

        expect(presenter.state_title).to eq("Errored")
      end
    end

    describe "errored?" do
      it 'should return true when state is "errored"' do
        tag_mapping.state = "errored"

        expect(presenter.errored?).to be_truthy
      end

      it 'should return false when state is not "errored"' do
        tag_mapping.state = "tagged"

        expect(presenter.errored?).to be_falsey
      end
    end
  end
end
