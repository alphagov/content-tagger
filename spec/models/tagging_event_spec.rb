require 'rails_helper'

RSpec.describe TaggingEvent do
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
