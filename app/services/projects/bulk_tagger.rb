module Projects
  class BulkTagger
    def initialize(content_items:, taxons:)
      @content_ids = content_items
      @taxon_content_ids = taxons
    end

    def commit
      @content_ids.each do |id|
        content_item = ProjectContentItem.find(id)
        content_item.touch
        TagContentWorker.perform_async(content_item.content_id, @taxon_content_ids)
      end
    end

    def result
      @content_ids.reduce([]) do |acc, content_id|
        acc << { content_id: content_id, taxons: @taxon_content_ids }
      end
    end
  end
end
