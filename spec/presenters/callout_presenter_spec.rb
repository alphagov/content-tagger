require 'rails_helper'

RSpec.describe CalloutPresenter do
  context 'with an :edit page type' do
    let(:callout_presenter) do
      described_class.new(title: 'A title', page_type: :edit)
    end

    it 'should render' do
      expect(callout_presenter.should_render?).to be_truthy
    end

    it 'has a callout class set' do
      expect(callout_presenter.callout_class).to eq('callout-warning')
    end

    it 'has a callout title set' do
      expect(callout_presenter.callout_title).to match(/editing/i)
    end
  end

  context 'with a :new page type' do
    let(:callout_presenter) do
      described_class.new(title: 'A title', page_type: :new)
    end

    it 'should render' do
      expect(callout_presenter.should_render?).to be_truthy
    end

    it 'has a callout class set' do
      expect(callout_presenter.callout_class).to eq('callout-info')
    end

    it 'has a callout title set' do
      expect(callout_presenter.callout_title).to match(/creating/i)
    end
  end

  context 'without a page type' do
    let(:callout_presenter) do
      described_class.new(title: 'A title')
    end

    it 'should not render' do
      expect(callout_presenter.should_render?).to be_falsy
    end

    it 'does not have a callout class set' do
      expect(callout_presenter.callout_class).to be_nil
    end

    it 'does not have a callout title set' do
      expect(callout_presenter.callout_title).to be_nil
    end
  end
end
