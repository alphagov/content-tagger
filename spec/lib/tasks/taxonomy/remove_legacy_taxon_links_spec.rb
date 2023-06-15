require "gds_api/test_helpers/publishing_api"

RSpec.describe "taxonomy:remove_legacy_taxon_links" do
  include ::GdsApi::TestHelpers::PublishingApi
  include RakeTaskHelper

  let(:content_ids_with_legacy_taxons) { %w[0133b1b3-9ecd-48ad-b226-538b46a17ff4 02b042bb-b875-4362-ba13-41cbfb70f242] }
  let(:content_ids_without_legacy_taxons) { %w[02c066d1-658e-4257-95b0-d9af0a358e5d 02fdbc1c-89ff-493c-a150-2a2b5e40cc5d] }
  let(:file) { instance_double(File) }

  before do
    allow(File).to receive(:open).and_return(file)
    allow(file).to receive(:readlines).and_return(content_ids_with_legacy_taxons + content_ids_without_legacy_taxons)
  end

  it "makes calls to patch links when the existing links contain legacy taxons" do
    links_without_legacy_taxons = { "parent-taxons" => %w[taxon-id-1 taxon-id-2] }
    links_with_legacy_taxons = links_without_legacy_taxons.merge("legacy_taxons" => %w[legacy-taxon-id-1])

    content_ids_with_legacy_taxons.each do |content_id|
      stub_publishing_api_has_links("content_id" => content_id, "links" => links_with_legacy_taxons)
    end

    content_ids_without_legacy_taxons.each do |content_id|
      stub_publishing_api_has_links("content_id" => content_id, "links" => links_without_legacy_taxons)
    end

    content_ids_with_legacy_taxons.each do |content_id|
      expect(Services.publishing_api).to receive(:patch_links).with(content_id, links: { legacy_taxons: [] }).once
    end

    content_ids_without_legacy_taxons.each do |content_id|
      expect(Services.publishing_api).not_to receive(:patch_links).with(content_id, links: { legacy_taxons: [] })
    end

    expect {
      rake("taxonomy:remove_legacy_taxon_links")
    }.to output(/updated 2 taxons to remove legacy taxon links/).to_stdout
  end
end
