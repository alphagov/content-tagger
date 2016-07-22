require "rails_helper"

RSpec.feature "Bulk taxon import", type: :feature do
  require 'gds_api/test_helpers/publishing_api_v2'
  include GdsApi::TestHelpers::PublishingApiV2

  given(:test_import_file_location) do
    FileUtils.mkdir_p(Rails.root + "tmp")
    File.join(Rails.root + "tmp", "bulk_taxon_import_feature_spec.tsv")
  end

  before do
    # Some of the objects involved in this test are quite noisy to STDOUT by
    # default - make a dummy logger available to hide the output.
    @dummy_logger = Logger.new(StringIO.new)
  end

  after do
    File.delete(test_import_file_location) if File.exist?(test_import_file_location)
  end

  scenario "Importing taxons" do
    given_taxonomy_data_is_available_from_a_remote_location
    and_i_have_populated_a_local_import_file
    and_the_import_file_contains_both_existing_and_non_existing_taxons
    when_i_run_the_taxon_creator
    then_only_the_appropriate_taxons_are_created
  end

  scenario "Linking taxons" do
    given_taxonomy_data_is_available_from_a_remote_location
    and_i_have_populated_a_local_import_file
    and_all_of_the_import_file_taxons_exist
    when_i_run_the_taxon_linker
    then_taxon_links_are_updated
  end

  def given_taxonomy_data_is_available_from_a_remote_location
    @the_key = 'the-key'
    @the_gid = 'the-gid'
    stub_request(
      :get, "https://docs.google.com/spreadsheets/d/#{@the_key}/pub?gid=#{@the_gid}&single=true&output=tsv"
    ).to_return(body: "mapped to\tlink\n" + "foo-taxon\t/test-path-1\n" + "bar-taxon\t/test-path-2\n")
  end

  def and_i_have_populated_a_local_import_file
    allow(AlphaTaxonomy::ImportFile).to receive(:location).and_return(test_import_file_location)
    AlphaTaxonomy::ImportFile.new(logger: @dummy_logger, sheet_identifiers: ['test-sheet', @the_key, @the_gid]).populate

    expect(File.exist?(test_import_file_location)).to be true
    expect(IO.readlines(test_import_file_location)).to include("foo-taxon\t/test-path-1\n")
    expect(IO.readlines(test_import_file_location)).to include("bar-taxon\t/test-path-2\n")
  end

  def and_the_import_file_contains_both_existing_and_non_existing_taxons
    # mimic a state where only the bar taxon already exists
    publishing_api_response = [
      { title: "bar-taxon", base_path: "/alpha-taxonomy/bar-taxon" }
    ]
    stub_request(
      :get, "#{PUBLISHING_API}/v2/linkables?document_type=taxon"
    ).to_return(body: publishing_api_response.to_json)
  end

  def when_i_run_the_taxon_creator
    # Make uuid generation and the current time deterministic
    fake_uuid = "0da87838-ad87-4160-8594-b26a38a9c06b"
    allow(SecureRandom).to receive(:uuid).and_return(fake_uuid)
    allow(DateTime).to receive(:current).and_return(DateTime.new(0))

    stub_publishing_api_calls(fake_uuid)

    AlphaTaxonomy::TaxonCreator.new(logger: @dummy_logger).run!
  end

  def stub_publishing_api_calls(fake_uuid)
    foo_taxon_payload = AlphaTaxonomy::TaxonPresenter.new(title: "foo-taxon").present
    @create_foo_taxon  = stub_publishing_api_put_content(fake_uuid, foo_taxon_payload)
    @publish_foo_taxon = stub_publishing_api_publish(fake_uuid, "update_type" => "major")
    bar_taxon_payload = AlphaTaxonomy::TaxonPresenter.new(title: "bar-taxon").present
    @create_bar_taxon = stub_publishing_api_put_content(fake_uuid, bar_taxon_payload)
  end

  def then_only_the_appropriate_taxons_are_created
    expect(@create_foo_taxon).to have_been_requested
    expect(@publish_foo_taxon).to have_been_requested

    expect(@create_bar_taxon).to_not have_been_requested
  end

  def and_all_of_the_import_file_taxons_exist
    publishing_api_response = [
      { title: "foo-taxon", base_path: "/alpha-taxonomy/foo-taxon", content_id: "foo-uuid" },
      { title: "bar-taxon", base_path: "/alpha-taxonomy/bar-taxon", content_id: "bar-uuid" }
    ]
    stub_request(
      :get, "#{PUBLISHING_API}/v2/linkables?document_type=taxon"
    ).to_return(body: publishing_api_response.to_json)
  end

  def when_i_run_the_taxon_linker
    publishing_api_has_lookups(
      '/test-path-1' => 'uuid-1',
      '/test-path-2' => 'uuid-2',
    )

    @update_links_1 = stub_publishing_api_patch_links("uuid-1", links: { taxons: ["foo-uuid"] })
    @update_links_2 = stub_publishing_api_patch_links("uuid-2", links: { taxons: ["bar-uuid"] })

    AlphaTaxonomy::TaxonLinker.new(logger: @dummy_logger).run!
  end

  def then_taxon_links_are_updated
    expect(@update_links_1).to have_been_requested
    expect(@update_links_2).to have_been_requested
  end
end
