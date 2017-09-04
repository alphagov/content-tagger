module Projects
  class PrepareContentItems
    def self.call(content_items)
      new(content_items).call
    end

    def initialize(content_items)
      @content_items = content_items
    end

    def call
      content_items.each do |content_item|
        content_item.taxons = taxons_for(content_item)
      end
    end

  private

    attr_reader :content_items

    def taxons_for(content_item)
      content_tags.dig(content_item.content_id, 'links', 'taxons') || []
    end

    def content_tags
      @_tags ||= Services.publishing_api.get_links_for_content_ids(content_ids)
    end

    def content_ids
      @_content_ids ||= content_items.map(&:content_id)
    end
  end
end
