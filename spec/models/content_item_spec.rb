require 'rails_helper'

RSpec.describe ContentItem do
  describe '#blacklisted_tag_types' do
    it "includes per-app blacklisted types" do
      configure_blacklist('blacklisted-app' => %w(foo bar))

      content_item = build_content_item(publishing_app: 'blacklisted-app')

      expect(content_item.blacklisted_tag_types).to include(:foo, :bar)
    end

    it "includes topics for specialist-publisher docs" do
      content_item = build_content_item(
        document_type: 'finder',
        publishing_app: 'specialist-publisher'
      )

      expect(content_item.blacklisted_tag_types).to include(:topics)
    end

    it "includes related items by default" do
      content_item = build_content_item(
        document_type: 'literally-anything',
      )

      expect(content_item.blacklisted_tag_types).to include(:ordered_related_items)
    end

    it "does not include related items for selected document types" do
      content_item = build_content_item(
        document_type: 'guide', # or calculator, answer, etc
      )

      expect(content_item.blacklisted_tag_types).not_to include(:ordered_related_items)
    end

    it "includes related item overrides if there's no taxons tagged to the item" do
      content_item = build_content_item

      allow(content_item).to receive(:taxons?) { false }

      expect(content_item.blacklisted_tag_types).to include(:ordered_related_items_overrides)
    end

    it "does not includes related item overrides if there's taxons tagged to the item" do
      content_item = build_content_item

      allow(content_item).to receive(:taxons?) { true }

      expect(content_item.blacklisted_tag_types).not_to include(:ordered_related_items_overrides)
    end
  end

  def build_content_item(data = {})
    item = ContentItem.new({
      base_path: double,
      content_id: double,
      document_type: double,
      publishing_app: double,
      rendering_app: 'frontend',
      title: double,
    }.merge(data).stringify_keys, blacklist: @blacklist || {})

    allow(item).to receive(:taxons?)

    item
  end

  def configure_blacklist(blacklist)
    @blacklist = blacklist
  end
end
