require "rails_helper"
require "gds_api/test_helpers/content_store"

RSpec.describe "taxonomy:health_checks" do
  include ::GdsApi::TestHelpers::ContentStore
  include PublishingApiHelper
  include ContentItemHelper
  include RakeTaskHelper
  include ActiveJob::TestHelper

  it "queues the expected jobs" do
    ActiveJob::Base.queue_adapter = :test

    expect {
      rake "taxonomy:health_checks"
    }.to change(TaxonomyHealth::MaximumDepthMetric.jobs, :size).by(1)
    .and change(TaxonomyHealth::ContentCountMetric.jobs, :size).by(1)
    .and change(TaxonomyHealth::ChildTaxonCountMetric.jobs, :size).by(1)
  end
end
