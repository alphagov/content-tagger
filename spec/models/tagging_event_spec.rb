require 'rails_helper'

RSpec.describe TaggingEvent do
  describe ".content_count_over_time" do
    before do
      @taxon_id = SecureRandom.uuid
      create(:tagging_event, taxon_content_id: @taxon_id, tagged_on: 2.weeks.ago)
      create(:tagging_event, taxon_content_id: @taxon_id, tagged_on: 4.weeks.ago)
    end

    let(:result) { TaggingEvent.content_count_over_time(@taxon_id) }

    it "returns 6 months worth of weeks" do
      expect(result.size).to be_in (25..27).to_a
    end

    it "returns the cumulative count of content tagged to a taxon" do
      expect(result[Date.today.monday]).to eq 2
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
