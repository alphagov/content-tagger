require 'rails_helper'

RSpec.describe ContentItem do
  let(:content_item_params) do
    {
      'content_id'     => 'uuid-88',
      'title'          => 'A content item',
      'document_type'  => 'placeholder',
      'base_path'      => '/a-content-item',
      'publishing_app' => 'publisher',
      'rendering_app'  => 'frontend',
    }
  end

  describe "#blacklisted_tag_types" do
    context "for apps in the blacklist" do
      let(:content_item) do
        ContentItem.new(
          content_item_params.merge('publishing_app' => 'travel-advice-publisher')
        )
      end

      it "returns the blacklisted fields" do
        expect(content_item.blacklisted_tag_types).to eq [:parent]
      end
    end

    context "for apps not in the blacklist" do
      let(:content_item) do
        ContentItem.new(
          content_item_params.merge('publishing_app' => 'not-in-the-blacklist')
        )
      end

      it "returns an empty list" do
        expect(content_item.blacklisted_tag_types).to eq []
      end
    end

    context "for rendering apps with a sidebar" do
      let(:content_item) do
        ContentItem.new(
          content_item_params.merge('publishing_app' => 'not-in-the-blacklist', 'rendering_app' => 'frontend')
        )
      end

      it "returns an empty list" do
        expect(content_item.blacklisted_tag_types).to eq []
      end
    end

    context "for rendering apps without a sidebar" do
      let(:content_item) do
        ContentItem.new(
          content_item_params.merge('publishing_app' => 'not-in-the-blacklist', 'rendering_app' => 'whitehall-frontend')
        )
      end

      it "blacklists related items" do
        expect(content_item.blacklisted_tag_types).to eq [:ordered_related_items]
      end
    end

    context "for finder blacklisting during specialist-publisher migration" do
      let(:content_item) do
        ContentItem.new(
          content_item_params.merge(
            'publishing_app' => 'specialist-publisher',
            'document_type' => 'finder',
          )
        )
      end

      it "blacklists topics as well as other tag types" do
        expect(content_item.blacklisted_tag_types).to include :topics
      end
    end

    context 'for the publisher app' do
      let(:content_item) do
        ContentItem.new(
          content_item_params.merge(
            'publishing_app' => 'publisher',
          )
        )
      end

      it 'does not blacklist any tag types' do
        expect(content_item.blacklisted_tag_types).to be_empty
      end
    end
  end
end
