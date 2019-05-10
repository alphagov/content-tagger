require 'rake'
require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'
require 'gds_api/test_helpers/rummager'

RSpec.describe 'facets:patch_links_to_facet_group' do
  include GdsApi::TestHelpers::PublishingApiV2
  include GdsApi::TestHelpers::Rummager
  include ContentItemHelper
  include PublishingApiHelper

  let(:results) do
    [
      { 'link' =>  "/link/one" },
      { 'link' =>  "/link/two" },
      { 'link' =>  "/link/three" },
    ]
  end

  let(:facet_group_content_id) { "FACET-GROUP-CONTENT-ID" }
  let(:finder_content_id) { "FINDER-CONTENT-ID" }
  let(:finder_service_class) { Facets::FinderService }
  let(:finder_service) { double(:finder_service, pinned_item_links: []) }
  let(:publishing_api) { Services.publishing_api }

  before :each do
    Rails.application.load_tasks
    stub_any_rummager_search.to_return(body: { 'results' => results }.to_json)
    stub_publishing_api_has_lookups(
      "/link/one" => "11111-11111-11111",
      "/link/two" => "22222-22222-22222",
      "/link/three" => "33333-33333-33333",
    )

    stub_const("#{finder_service_class}::LINKED_FINDER_CONTENT_ID", finder_content_id)
    allow(finder_service_class).to receive(:new).and_return(finder_service)
    allow(publishing_api).to receive(:patch_links)
  end

  it "updates all content tagged to a facet group" do
    Rake::Task['facets:patch_links_to_facet_group'].invoke(facet_group_content_id)
    expect(publishing_api).to have_received(:patch_links).exactly(3).times
  end
end
