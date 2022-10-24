RSpec.describe "taxonomy:health_checks" do
  include RakeTaskHelper
  include ActiveJob::TestHelper

  it "queues the expected jobs" do
    ActiveJob::Base.queue_adapter = :test

    Sidekiq::Testing.fake! do
      expect { rake "taxonomy:health_checks" }
        .to output.to_stdout
        .and change(TaxonomyHealth::MaximumDepthMetric.jobs, :size).by(1)
        .and change(TaxonomyHealth::ContentCountMetric.jobs, :size).by(1)
        .and change(TaxonomyHealth::ChildTaxonCountMetric.jobs, :size).by(1)
    end
  end
end
