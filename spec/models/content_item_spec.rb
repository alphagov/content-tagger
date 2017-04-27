require 'rails_helper'

RSpec.describe ContentItem do
  let(:content_item) do
    ContentItem.new(
      content_item_params
    ).tap do |content_item|
      content_item.link_set = Tagging::ContentItemExpandedLinks.new(link_set_params)
    end
  end

  let(:content_item_params) do
    {
      'content_id'     => 'uuid-88',
      'title'          => 'A content item',
      'document_type'  => 'placeholder',
      'base_path'      => '/a-content-item',
      'publishing_app' => 'publisher',
      'rendering_app'  => 'frontend',
      'state'          => 'draft',
    }
  end

  let(:link_set_params) do
    {
      'content_id'     => 'uuid-88',
      'previous_version' => 0,
    }
  end

  describe "#blacklisted_tag_types" do
    context "without taxons" do
      let(:content_item_params) do
        super().merge('publishing_app' => 'not-in-the-blacklist')
      end

      it "blacklists related item overrides for content not tagged to taxons" do
        expect(content_item.blacklisted_tag_types).to eq [:ordered_related_items_overrides]
      end
    end

    context "with taxons" do
      let(:link_set_params) do
        super().merge('taxons' => ["6fde156c-98f3-4045-ac21-c64fcf1677e5"])
      end

      context "for apps in the blacklist" do
        let(:content_item_params) do
          super().merge('publishing_app' => 'test-app-that-can-be-tagged-to-topics-only')
        end

        it "returns the blacklisted fields" do
          expect(content_item.blacklisted_tag_types)
            .to eq(
                  %i(
                    mainstream_browse_pages
                    meets_user_needs
                    ordered_related_items
                    ordered_related_items_overrides
                    organisations
                    parent
                    taxons
                  )
                )
        end
      end

      context "for apps not in the blacklist" do
        let(:content_item_params) do
          super().merge('publishing_app' => 'not-in-the-blacklist')
        end

        it "returns an empty list" do
          expect(content_item.blacklisted_tag_types).to eq []
        end
      end

      context "for rendering apps with a sidebar" do
        let(:content_item_params) do
          super().merge('publishing_app' => 'not-in-the-blacklist', 'rendering_app' => 'frontend')
        end

        it "returns an empty list" do
          expect(content_item.blacklisted_tag_types).to eq []
        end
      end

      context "for rendering apps without a sidebar" do
        let(:content_item_params) do
          super().merge('publishing_app' => 'not-in-the-blacklist', 'rendering_app' => 'whitehall-frontend')
        end

        it "blacklists related items" do
          expect(content_item.blacklisted_tag_types).to eq [:ordered_related_items]
        end
      end

      context "for finder blacklisting during specialist-publisher migration" do
        let(:content_item_params) do
          super().merge(
            'publishing_app' => 'specialist-publisher',
            'document_type' => 'finder',
          )
        end

        it "blacklists topics as well as other tag types" do
          expect(content_item.blacklisted_tag_types).to include :topics
        end
      end

      context 'for the publisher app' do
        let(:content_item_params) do
          super().merge(
            'publishing_app' => 'publisher',
          )
        end

        it 'does not blacklist any tag types' do
          expect(content_item.blacklisted_tag_types).to be_empty
        end
      end
    end
  end
end
