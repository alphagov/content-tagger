require 'rails_helper'

RSpec.describe ContentItem do
  let(:content_item_params) do
    {
      'content_id'     => 'uuid-88',
      'title'          => 'A content item',
      'format'         => 'placeholder',
      'base_path'      => '/a-content-item',
      'publishing_app' => 'whitehall'
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
        content_item.blacklisted_tag_types == ['parent']
      end
    end

    context "for apps not in the blacklist" do
      let(:content_item) { ContentItem.new(content_item_params) }

      it "returns an empty list" do
        content_item.blacklisted_tag_types == []
      end
    end
  end
end
