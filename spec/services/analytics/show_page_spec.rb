require 'rails_helper'

RSpec.describe Analytics::ShowPage do
  subject { described_class.new(taxon_id) }
  let(:taxon_id) { SecureRandom.uuid }

  describe "#title" do
    let(:result) { subject.title }

    before do
      allow(Taxonomy::BuildTaxon)
        .to receive(:call)
        .with(content_id: taxon_id)
        .and_return(
          build(:taxon, title: 'I am a title')
        )
    end

    it "returns the title from the taxon in the publishing_api" do
      expect(result).to eq 'I am a title'
    end
  end

  describe "#content_count_over_time" do
    before do
      create(:tagging_event, :guidance, taxon_content_id: taxon_id, tagged_on: 2.weeks.ago)
      create(:tagging_event, taxon_content_id: taxon_id, tagged_on: 4.weeks.ago)
    end

    let(:result) { subject.content_count_over_time }

    it "returns two time series" do
      expect(result.size).to eq 2
    end

    it "returns a guidance time series" do
      expect(result.any? { |r| r[:name] == 'Guidance' }).to be true
    end

    it "returns an 'other content' series" do
      expect(result.any? { |r| r[:name] == 'Other content' }).to be true
    end

    it "returns 6 months worth of weeks" do
      expect(result[0][:data].size).to be_in((25..27).to_a)
    end

    it "returns the cumulative count of content tagged to a taxon" do
      expect(result[0][:data][Date.today.monday]).to eq 1
      expect(result[1][:data][Date.today.monday]).to eq 1
    end
  end
end
