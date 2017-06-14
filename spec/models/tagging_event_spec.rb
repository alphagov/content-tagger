require 'rails_helper'

RSpec.describe TaggingEvent do
  describe ".content_count_over_time" do
    before do
      @taxon_id = SecureRandom.uuid
      create(:tagging_event, :guidance, taxon_content_id: @taxon_id, tagged_on: 2.weeks.ago)
      create(:tagging_event, taxon_content_id: @taxon_id, tagged_on: 4.weeks.ago)
    end

    let(:result) { TaggingEvent.content_count_over_time(@taxon_id) }

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

  describe "#guidance?" do
    let(:result) { TaggingEvent.new(taggable_navigation_document_supertype: @supertype).guidance? }

    it "is true when the taggable_navigation_document_supertype is 'guidance'" do
      @supertype = 'guidance'
      expect(result).to be true
    end

    it "is false when the taggable_navigation_document_supertype is not 'guidance'" do
      @supertype = 'wibble'
      expect(result).to be false
    end
  end

  describe "#added?" do
    it "is true when change is +ve" do
      expect(TaggingEvent.new(change: 1).added?).to be true
    end

    it "is false when change is -ve" do
      expect(TaggingEvent.new(change: -1).added?).to be false
    end
  end

  describe "#removed?" do
    it "is true when change is -ve" do
      expect(TaggingEvent.new(change: -1).removed?).to be true
    end

    it "is false when change is +ve" do
      expect(TaggingEvent.new(change: 1).removed?).to be false
    end
  end
end
