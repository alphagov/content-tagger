RSpec.describe ApplicationHelper, type: :helper do
  describe "#safe_href" do
    it "allows valid http and https URLs" do
      expect(helper.safe_href("https://example.com")).to eq("https://example.com")
      expect(helper.safe_href("http://example.com")).to eq("http://example.com")
    end

    it "trims leading and trailing whitespace" do
      expect(helper.safe_href("  https://example.com  ")).to eq("https://example.com")
    end

    it "blocks malicious javascript links" do
      expect(helper.safe_href("javascript:alert('XSS')")).to eq("#")
      expect(helper.safe_href("JAVASCRIPT:alert(1)")).to eq("#")
    end

    it "blocks unexpected protocols like data or ftp" do
      expect(helper.safe_href("data:text/html,payload")).to eq("#")
      expect(helper.safe_href("ftp://files.com")).to eq("#")
    end

    it "handles nil and empty values gracefully" do
      expect(helper.safe_href(nil)).to eq("#")
      expect(helper.safe_href("")).to eq("#")
    end

    it "handles completely malformed strings safely" do
      expect(helper.safe_href("just text")).to eq("#")
      expect(helper.safe_href("http://:invalid")).to eq("#")
    end
  end
end
