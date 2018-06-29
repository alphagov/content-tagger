require 'rails_helper'

module Metrics
  RSpec.describe SuperfluousTaggingsMetrics do
    describe '#count' do
      it "sends the correct values to statsd" do
        allow(Tagging::CommonAncestorFinder).to receive(:call)
                                         .and_return([{ content_id: 'id1', title: 'title1', common_ancestors: [1, 2] },
                                                      { content_id: 'id2', title: 'title2', common_ancestors: [3] }])

        allow(Metrics.statsd).to receive(:gauge)

        Metrics::SuperfluousTaggingsMetrics.new.count

        expect(Metrics.statsd).to have_received(:gauge)
                                    .with("superfluous_tagging_count", 3)
      end
    end
  end
end
