require 'rails_helper'

RSpec.describe LookupContentIdWorker do
  describe ".perform_async" do
    subject { described_class }

    it { is_expected.to respond_to :perform_async }
  end

  describe "#perform" do
    it "looks up the base_path from the DB" do
      content_item = create(:project_content_item, url: "https://www.gov.uk/base_path")
      expect(Services.publishing_api).to receive(:lookup_content_id).with(base_path: '/base_path')

      LookupContentIdWorker.new.perform(content_item.id)
    end

    it "persists the content_id against the local content_item" do
      content_item = create(:project_content_item, url: "https://www.gov.uk/base_path")
      content_item_id = SecureRandom.uuid

      allow(Services.publishing_api)
        .to receive(:lookup_content_id)
        .with(base_path: '/base_path')
        .and_return(content_item_id)

      LookupContentIdWorker.new.perform(content_item.id)

      content_item.reload
      expect(content_item.content_id).to eql content_item_id
    end

    it "does not raise an error if the content item cannot be found" do
      expect { LookupContentIdWorker.new.perform(123) }.to_not raise_error
    end
  end
end
