RSpec.describe Proxies::IframeAllowingProxy do
  let(:proxy) { described_class.new }

  describe "#rewrite_response" do
    context "when there is no content-type" do
      it "renders the original page" do
        body = ['<tag>href="/absolute/path"</tag>']
        expect(proxy.rewrite_response([{}, {}, body])[-1]).to eq(body)
      end
    end

    context "when the page contains html" do
      let(:headers) { { "content-type" => ["text/html; charset=utf-8"] } }

      it "prepends base url to all absolute URLs - href" do
        body = ['<tag>href="/absolute/path"</tag>']
        expect(proxy.rewrite_response([{}, headers, body])[-1]).to eq(['<tag>href="/iframe-proxy/absolute/path"</tag>'])
      end

      it "prepends base url to all absolute URLs - src" do
        body = ['<tag src="/absolute/path"></tag>']
        expect(proxy.rewrite_response([{}, headers, body])[-1]).to eq(['<tag src="/iframe-proxy/absolute/path"></tag>'])
      end

      it "prepends base url to all absolute URLs - different quotes" do
        body = ["<tag href='/absolute/path'></tag>"]
        expect(proxy.rewrite_response([{}, headers, body])[-1]).to eq(['<tag href="/iframe-proxy/absolute/path"></tag>'])
      end

      it "replaces gov.uk to an absolute path and prepends base url" do
        body = ['<tag>href="https://gov.uk/absolute/path"</tag>']
        expect(proxy.rewrite_response([{}, headers, body])[-1]).to eq(['<tag>href="/iframe-proxy/absolute/path"</tag>'])
      end

      it "replaces www.gov.uk to an absolute path and prepends base url" do
        body = ['<tag>href="https://www.gov.uk/absolute/path"</tag>']
        expect(proxy.rewrite_response([{}, headers, body])[-1]).to eq(['<tag>href="/iframe-proxy/absolute/path"</tag>'])
      end

      it "does not rewrite urls from other domains" do
        body = ['<link href="https://assets.publishing.service.gov.uk/static/>']
        expect(proxy.rewrite_response([{}, headers, body])[-1]).to eq(body)
      end
    end

    context "when the page contains a pdf" do
      let(:headers) { { "content-type" => ["application/x-pdf"] } }

      it "does not rewrite urls" do
        body = ['<tag>href="/absolute/path"</tag>']
        expect(proxy.rewrite_response([{}, headers, body])[-1]).to eq(['<tag>href="/absolute/path"</tag>'])
      end
    end
  end
end
