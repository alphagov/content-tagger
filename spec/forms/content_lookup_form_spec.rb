require 'rails_helper'

RSpec.describe ContentLookupForm do
  describe '#valid?' do
    it "is not valid when path is empty" do
      form = ContentLookupForm.new(base_path: '')

      expect(form).to_not be_valid
    end

    it "is not valid when path is an invalid URL" do
      form = ContentLookupForm.new(base_path: 'Some Weird URL')

      expect(form).to_not be_valid
    end

    it "is invalid when the path not found on GOV.UK" do
      stub_request(:get, "https://draft-content-store.test.gov.uk/content/browse")
        .to_return(status: 404)

      form = ContentLookupForm.new(base_path: '/browse')

      expect(form).to_not be_valid
    end

    it "is valid when the path is an absolute_path found on GOV.UK" do
      stub_request(:get, "https://draft-content-store.test.gov.uk/content/browse")
        .to_return(body: { format: 'placeholder' }.to_json)

      form = ContentLookupForm.new(base_path: '/browse')

      expect(form).to be_valid
    end

    it "is invalid when the path is not renderable" do
      stub_request(:get, "https://draft-content-store.test.gov.uk/content/browse")
        .to_return(body: { format: 'redirect' }.to_json)

      form = ContentLookupForm.new(base_path: '/browse')

      expect(form).not_to be_valid
    end

    it "treats paths and URLs the same" do
      stub_request(:get, "https://draft-content-store.test.gov.uk/content/browse")
        .to_return(body: { format: 'placeholder' }.to_json)

      form = ContentLookupForm.new(base_path: 'http://gov.uk/browse')

      expect(form).to be_valid
    end
  end
end
