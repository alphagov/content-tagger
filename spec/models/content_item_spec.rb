RSpec.describe ContentItem do
  describe "#denylisted_tag_types" do
    it "includes per-app denylisted types" do
      content_item = build_content_item(
        data: { publishing_app: "denylisted-app" },
        denylist: { "denylisted-app" => %w[foo bar] },
      )

      expect(content_item.denylisted_tag_types).to include(:foo, :bar)
    end

    it "includes topics for specialist-publisher docs" do
      content_item = build_content_item(
        data: { document_type: "finder", publishing_app: "specialist-publisher" },
      )

      expect(content_item.denylisted_tag_types).to include(:topics)
    end

    it "includes related items by default" do
      content_item = build_content_item(
        data: { document_type: "literally-anything" },
      )

      expect(content_item.denylisted_tag_types).to include(:ordered_related_items)
    end

    it "does not include related items for selected document types" do
      content_item = build_content_item(
        data: { document_type: "guide" }, # or calculator, answer, etc
      )

      expect(content_item.denylisted_tag_types).not_to include(:ordered_related_items)
    end

    it "includes related item overrides if there's no taxons tagged to the item" do
      content_item = build_content_item

      allow(content_item).to receive(:taxons?).and_return(false)

      expect(content_item.denylisted_tag_types).to include(:ordered_related_items_overrides)
    end

    it "does not includes related item overrides if there's taxons tagged to the item" do
      content_item = build_content_item

      allow(content_item).to receive(:taxons?).and_return(true)

      expect(content_item.denylisted_tag_types).not_to include(:ordered_related_items_overrides)
    end

    it "includes suggested related items if there's no suggestions for the item" do
      content_item = build_content_item

      allow(content_item).to receive(:suggested_related_links?).and_return(false)

      expect(content_item.denylisted_tag_types).to include(:suggested_ordered_related_items)
    end

    it "does not include suggested related items if suggestions exist for the item" do
      content_item = build_content_item

      allow(content_item).to receive(:suggested_related_links?).and_return(true)

      expect(content_item.denylisted_tag_types).not_to include(:suggested_ordered_related_items)
    end
  end

  def build_content_item(data: {}, denylist: {})
    item = ContentItem.new(
      {
        base_path: double,
        content_id: double,
        description: double,
        document_type: double,
        publishing_app: double,
        rendering_app: "frontend",
        title: double,
      }.merge(data).stringify_keys,
      denylist: denylist || {},
    )

    allow(item).to receive(:taxons?)
    allow(item).to receive(:suggested_related_links?)

    item
  end
end
