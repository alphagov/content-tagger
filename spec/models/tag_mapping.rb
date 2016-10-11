require 'rails_helper'

RSpec.describe TagMapping do
  let(:tag_mapping) { build(:tag_mapping) }

  describe "validations" do
    it "validates with these validators" do
      expect(described_class.validators).to include(instance_of(ContentIdValidator))
      expect(described_class.validators).to include(instance_of(LinkTypeValidator))
    end
  end

  describe "#content_id" do
    it "finds the content id from the base path" do
      content_id = "content-1-ID"
      publishing_api_has_lookups(tag_mapping.content_base_path => content_id)

      expect(tag_mapping.content_id).to eq(content_id)
    end
  end

  context '#messages' do
    it 'serializes the messages as an array' do
      expect { subject.messages = ['a message'] }.to_not raise_error
    end

    it "doesn't allow other types in the messages field" do
      expect { subject.messages = 'a message' }.to raise_error(
        ActiveRecord::SerializationTypeMismatch
      )
    end
  end

  describe "#mark_as_tagged" do
    it "marks a number of tag mappings as tagged" do
      expect { tag_mapping.mark_as_tagged }.to change { tag_mapping.state }.to("tagged")
    end

    it "adds a publish_completed_at date" do
      expect { tag_mapping.mark_as_tagged }.to change { tag_mapping.publish_completed_at }
    end
  end

  describe "#mark_as_errored" do
    context "when the links update is valid" do
      it "doesn't change the tag mapping state" do
        expect { tag_mapping.mark_as_errored }
          .to_not change { tag_mapping.state }
      end

      it "doesn't change the tag mapping messages" do
        expect { tag_mapping.mark_as_errored }
          .to_not change { tag_mapping.messages }
      end

      it "doesn't change the state of the tagging source" do
        expect { tag_mapping.mark_as_errored }
          .to_not change { tag_mapping.tagging_source }
      end
    end

    context "when the links update is invalid" do
      before do
        tag_mapping.errors.add(:links, "Broken.")
        tag_mapping.errors.add(:content_id, "Rubbish.")
      end

      it "updates the tag mapping state" do
        expect { tag_mapping.mark_as_errored }
          .to change { tag_mapping.state }
          .to("errored")
      end

      it "assigns the error messages to the record" do
        expect { tag_mapping.mark_as_errored }
          .to change { tag_mapping.messages }
          .to(["Broken.", "Rubbish."])
      end

      it 'changes the state of the tagging source to errored' do
        expect { tag_mapping.mark_as_errored }
          .to change { tag_mapping.tagging_source.state }
          .to('errored')
      end

      it 'changes the error message of the tagging source' do
        expect { tag_mapping.mark_as_errored }
          .to change { tag_mapping.tagging_source.error_message }
          .to(/we could not tag all items/i)
      end
    end
  end
end
