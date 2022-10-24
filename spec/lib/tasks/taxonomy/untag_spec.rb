RSpec.describe "taxonomy:untag", type: :task do
  include RakeTaskHelper

  it "invokes untagger" do
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linked/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa?fields%5B%5D=content_id&fields%5B%5D=title&link_type=taxons")
     .to_return(status: 200, body: [{ "content_id" => "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb" }].to_json, headers: {})

    expect(Tagging::Untagger).to receive(:call).with("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb", %w[aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa])

    expect { rake("taxonomy:untag", %w[aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa untag]) }
      .to output.to_stdout
  end

  it "does nothing if no arguments are given" do
    expect(Tagging::Untagger).not_to receive(:call)

    expect { rake("taxonomy:untag") }.to output.to_stderr
  end
end
