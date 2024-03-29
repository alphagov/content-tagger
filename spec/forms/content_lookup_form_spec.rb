RSpec.describe ContentLookupForm do
  describe "#valid?" do
    it "is not valid when path is empty" do
      form = described_class.new(base_path: "")

      expect(form).not_to be_valid
    end

    it "is not valid when path is an invalid URL" do
      form = described_class.new(base_path: "Some Weird URL")

      expect(form).not_to be_valid
    end

    it "is invalid when the path not found on GOV.UK" do
      stub_publishing_api_has_lookups({})

      form = described_class.new(base_path: "/browse")

      expect(form).not_to be_valid
    end

    it "is valid when the path is an absolute_path found on GOV.UK" do
      stub_publishing_api_has_lookups(
        "/browse" => "a96c1542-..",
      )

      form = described_class.new(base_path: "/browse")

      expect(form).to be_valid
    end

    it "treats paths and URLs the same" do
      stub_publishing_api_has_lookups(
        "/browse" => "a96c1542-..",
      )

      form = described_class.new(base_path: "http://gov.uk/browse")

      expect(form).to be_valid
    end
  end
end
