require 'rails_helper'

RSpec.describe ProjectContentItem do
  let(:proxy_path) { Proxies::IframeAllowingProxy::PROXY_BASE_PATH.chomp('/') }

  describe '#proxied_url' do
    it 'changes to relative proxied path for http://www.gov.uk' do
      content_item = build(:project_content_item, url: 'http://www.gov.uk/path')
      expect(content_item.proxied_url).to eq("#{proxy_path}/path")
    end
    it 'changes to relative proxied path for https://www.gov.uk' do
      content_item = build(:project_content_item, url: 'https://www.gov.uk/path')
      expect(content_item.proxied_url).to eq("#{proxy_path}/path")
    end
    it 'changes to relative proxied path for http://gov.uk' do
      content_item = build(:project_content_item, url: 'http://gov.uk/path')
      expect(content_item.proxied_url).to eq("#{proxy_path}/path")
    end
    it 'changes to relative proxied path for https://gov.uk' do
      content_item = build(:project_content_item, url: 'https://gov.uk/path')
      expect(content_item.proxied_url).to eq("#{proxy_path}/path")
    end
  end
end
