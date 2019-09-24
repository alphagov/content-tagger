require "rails_helper"

RSpec.describe Projects::BulkTagger do
  let(:params) { { content_items: content_item_ids, taxons: taxons } }
  let(:content_item_ids) { content_items.map(&:id) }
  let(:content_items) { Array.new(1) { create(:project_content_item) } }
  let(:taxons) { Array.new(3) { SecureRandom.uuid } }

  before do
    allow(Projects::TagContentWorker).to receive(:perform_async)
  end

  describe "#commit" do
    it "enqueues the content_items for tagging asynchronously" do
      Projects::BulkTagger.new(params).commit

      expect(Projects::TagContentWorker)
        .to have_received(:perform_async)
        .with(content_items[0].content_id, taxons)
    end
  end

  describe "#result" do
    it "returns the correct datastructure" do
      bulk_tagger = Projects::BulkTagger.new(params)
      bulk_tagger.commit
      result = bulk_tagger.result

      expect(result).to eql [
        {
          content_id: content_items[0].id,
          taxons: taxons,
        },
      ]
    end
  end
end
