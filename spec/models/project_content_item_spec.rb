RSpec.describe ProjectContentItem do
  let(:proxy_path) { Proxies::IframeAllowingProxy::PROXY_BASE_PATH.chomp("/") }

  describe "#proxied_url" do
    it "changes to relative proxied path for http://www.gov.uk" do
      content_item = build(:project_content_item, url: "http://www.gov.uk/path")
      expect(content_item.proxied_url).to eq("#{proxy_path}/path")
    end
    it "changes to relative proxied path for https://www.gov.uk" do
      content_item = build(:project_content_item, url: "https://www.gov.uk/path")
      expect(content_item.proxied_url).to eq("#{proxy_path}/path")
    end
    it "changes to relative proxied path for http://gov.uk" do
      content_item = build(:project_content_item, url: "http://gov.uk/path")
      expect(content_item.proxied_url).to eq("#{proxy_path}/path")
    end
    it "changes to relative proxied path for https://gov.uk" do
      content_item = build(:project_content_item, url: "https://gov.uk/path")
      expect(content_item.proxied_url).to eq("#{proxy_path}/path")
    end
  end

  describe "#done!" do
    it "updates the content item to 'done' and saves it" do
      subject = create(:project_content_item, done: false)
      subject.done!
      expect(subject.done?).to be true
      expect(subject.persisted?).to be true
    end
  end
end
