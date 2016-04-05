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
        expect(content_item.blacklisted_tag_types).to eq ['parent']
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
  end

  describe '#app_responsible_for_tagging' do
    it "doesn't have one if the format is unrenderable" do
      item = ContentItem.new(
        content_item_params.merge(
          'format' => 'redirect',
          'publishing_app' => 'a-migrated-app',
        )
      )

      expect(item.app_responsible_for_tagging).to be_nil
    end
  end
end
