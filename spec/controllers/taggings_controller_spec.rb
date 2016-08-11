require 'rails_helper'

RSpec.describe TaggingsController, type: :controller do
  describe "#show" do
    it "renders 404 for unknown content items" do
      stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/does-not-exist")
        .to_return(status: 404)

      get :show, content_id: "does-not-exist"

      expect(response.code).to eql "404"
    end
  end
end
