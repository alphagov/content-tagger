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
      publishing_api_has_lookups({})

      form = ContentLookupForm.new(base_path: '/browse')

      expect(form).to_not be_valid
    end

    it "is valid when the path is an absolute_path found on GOV.UK" do
      publishing_api_has_lookups(
        '/browse' => 'a96c1542-..'
      )

      form = ContentLookupForm.new(base_path: '/browse')

      expect(form).to be_valid
    end

    it "treats paths and URLs the same" do
      publishing_api_has_lookups(
        '/browse' => 'a96c1542-..'
      )

      form = ContentLookupForm.new(base_path: 'http://gov.uk/browse')

      expect(form).to be_valid
    end
  end
end
