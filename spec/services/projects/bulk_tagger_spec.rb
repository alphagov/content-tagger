RSpec.describe Projects::BulkTagger do
  let(:params) { { content_items: content_item_ids, taxons: } }
  let(:content_item_ids) { content_items.map(&:id) }
  let(:content_items) { create_list(:project_content_item, 1) }
  let(:taxons) { Array.new(3) { SecureRandom.uuid } }

  before do
    allow(Projects::TagContentWorker).to receive(:perform_async)
  end

  describe "#commit" do
    it "enqueues the content_items for tagging asynchronously" do
      described_class.new(**params).commit

      expect(Projects::TagContentWorker)
        .to have_received(:perform_async)
        .with(content_items[0].content_id, taxons)
    end
  end

  describe "#result" do
    it "returns the correct datastructure" do
      bulk_tagger = described_class.new(**params)
      bulk_tagger.commit
      result = bulk_tagger.result

      expect(result).to eql [
        {
          content_id: content_items[0].id,
          taxons:,
        },
      ]
    end
  end
end
