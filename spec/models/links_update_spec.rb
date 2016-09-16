require "rails_helper"

RSpec.describe LinksUpdate do
  let(:links_update) do
    build(:links_update, links: { "taxons" => ["a-taxon-content-id"] })
  end

  describe "validations" do
    it "validates with these validators" do
      expect(LinksUpdate.validators).to include(instance_of(ContentIdValidator))
      expect(LinksUpdate.validators).to include(instance_of(LinkTypeValidator))
      expect(LinksUpdate.validators).to include(instance_of(TaxonsValidator))
    end
  end

  describe "#taxons" do
    it "returns the list of taxons" do
      expect(links_update.taxons).to eq(["a-taxon-content-id"])
    end
  end

  describe "#link_types" do
    it "returns the list of link types" do
      expect(links_update.link_types).to eq(["taxons"])
    end
  end

  describe "#content_id" do
    it "finds the content id from the base path" do
      content_id = "content-1-ID"
      publishing_api_has_lookups(links_update.base_path => content_id)

      expect(links_update.content_id).to eq(content_id)
    end
  end

  describe "#mark_as_tagged" do
    let(:tag_mapping) { create(:tag_mapping) }

    before do
      links_update.tag_mappings = TagMapping.all
    end

    it "marks a number of tag mappings as tagged" do
      expectation = lambda do
        links_update.mark_as_tagged
        tag_mapping.reload
      end

      expect { expectation.call }.to change { tag_mapping.state }.to("tagged")
    end

    it "adds a publish_completed_at date" do
      expectation = lambda do
        links_update.mark_as_tagged
        tag_mapping.reload
      end

      expect { expectation.call }.to change { tag_mapping.publish_completed_at }
    end
  end

  describe "#mark_as_errored" do
    let!(:tag_mapping) { create(:tag_mapping) }
    let(:links_update) { build(:links_update, tag_mappings: TagMapping.all) }

    context "when the links update is invalid" do
      before do
        links_update.errors.add(:links, "Broken.")
        links_update.errors.add(:content_id, "Rubbish.")

        links_update.mark_as_errored
        tag_mapping.reload
      end

      it "updates the tag mapping state" do
        expect(tag_mapping.state).to eql("errored")
      end

      it "assigns the error messages to the record" do
        expect(tag_mapping.messages).to eql(["Broken.", "Rubbish."])
      end

      it 'changes the state of the tagging source to errored' do
        expect(tag_mapping.tagging_source.state).to eq('errored')
      end

      it 'changes the error message of the tagging source' do
        tagging_source = tag_mapping.tagging_source
        expect(tagging_source.error_message).to match(/we could not tag all items/i)
      end
    end

    context "when the links update is valid" do
      let(:expectation) do
        lambda do
          links_update.mark_as_errored
          tag_mapping.reload
        end
      end

      it "doesn't change the tag mapping state" do
        expect { expectation.call }.to_not change { tag_mapping.state }
      end

      it "doesn't change the tag mapping messages" do
        expect { expectation.call }.to_not change { tag_mapping.messages }
      end

      it "doesn't change the state of the tagging source" do
        expect { expectation.call }.to_not change { tag_mapping.tagging_source }
      end
    end
  end
end
