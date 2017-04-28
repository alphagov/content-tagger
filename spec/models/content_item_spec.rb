require 'rails_helper'

RSpec.describe ContentItem do
  subject(:content_item) { described_class.new(data, blacklist: blacklist) }

  let(:data) do
    {
      'base_path' => double,
      'content_id' => double,
      'document_type' => document_type,
      'publishing_app' => publishing_app,
      'rendering_app' => rendering_app,
      'title' => double,
    }
  end

  let(:blacklist) do
    {
      'blacklisted-app' => blacklisted_tag_types,
    }
  end

  let(:document_type) { double }
  let(:publishing_app) { double }
  let(:rendering_app) { 'frontend' }

  let(:blacklisted_tag_types) do
    Tagging::ContentItemExpandedLinks::TAG_TYPES.sample(2)
  end

  before { allow(content_item).to receive(:taxons?) }

  describe '#blacklisted_tag_types' do
    subject { content_item.blacklisted_tag_types }

    context 'for apps in the blacklist' do
      let(:publishing_app) { 'blacklisted-app' }

      specify 'should include blacklisted tag types' do
        is_expected.to include(*blacklisted_tag_types)
      end
    end

    context 'for finder blacklisting during specialist-publisher migration' do
      let(:document_type) { 'finder' }
      let(:publishing_app) { 'specialist-publisher' }

      it { is_expected.to include(:topics) }
    end

    context 'for rendering apps with a sidebar' do
      let(:rendering_app) { 'frontend' }

      it { is_expected.not_to include(:ordered_related_items) }
    end

    context 'for rendering apps without a sidebar' do
      let(:rendering_app) { 'whitehall-frontend' }

      it { is_expected.to include(:ordered_related_items) }
    end

    context 'with taxons' do
      before { allow(content_item).to receive(:taxons?) { true } }

      it { is_expected.not_to include(:ordered_related_items_overrides) }
    end

    context 'without taxons' do
      before { allow(content_item).to receive(:taxons?) { false } }

      it { is_expected.to include(:ordered_related_items_overrides) }
    end
  end
end
