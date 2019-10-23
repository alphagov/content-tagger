# rubocop:disable Style/BlockDelimiters

require "rails_helper"
require "gds_api/test_helpers/content_store"

RSpec.describe "taxonomy:validate_taxons_base_paths" do
  include ActiveSupport::Testing::TimeHelpers
  include ::GdsApi::TestHelpers::ContentStore
  include PublishingApiHelper
  include ContentItemHelper
  include RakeTaskHelper

  it "outputs check as all-valid" do
    content_store_has_valid_two_level_tree

    expect {
      rake "taxonomy:validate_taxons_base_paths"
    }.to output(<<~LOG).to_stdout_from_any_process
      ✅ /level-one
      ✅    ├── /level-one/level-two
    LOG
  end

  it "does not fix the base paths by default" do
    content_store_has_tree_with_invalid_level_one_prefix

    expect {
      rake "taxonomy:validate_taxons_base_paths"
    }.to output(<<~LOG.strip).to_stdout_from_any_process
      ✅ /level-one
      ❌    ├── /some-other-path/level-two
      ------------------------------------
      The following taxons did not match the taxon URL structure.
      CONTENT-ID-LEVEL-TWO /some-other-path/level-two
    LOG
  end

  it "optionally fixes paths that do not have the correct level one prefix" do
    content_store_has_tree_with_invalid_level_one_prefix

    taxon_attributes = taxon_with_details(
      "Level Two",
      other_fields: {
        content_id: "CONTENT-ID-LEVEL-TWO",
        base_path: "/some-other-path/level-two",
        publication_state: "draft",
      },
    )

    publishing_api_has_item(taxon_attributes)
    publishing_api_has_expanded_links(taxon_attributes.slice(:content_id))
    stub_any_publishing_api_put_content

    expect {
      rake "taxonomy:validate_taxons_base_paths", "and_fix"
    }.to output(<<~LOG).to_stdout_from_any_process
      ✅ /level-one
      ❌    ├── /some-other-path/level-two
      ------------------------------------
      The following taxons did not match the taxon URL structure. Attempting to fix this...
      CONTENT-ID-LEVEL-TWO /some-other-path/level-two
        └─ /level-one/level-two
    LOG

    assert_publishing_api_put_content(
      taxon_attributes["content_id"],
      request_json_includes(base_path: "/level-one/level-two"),
    )
  end

  it "optionally fixes paths that do not have the correct level one prefix" do
    content_store_has_tree_with_long_base_path_structure

    taxon_attributes = taxon_with_details(
      "Level Two",
      other_fields: {
        content_id: "CONTENT-ID-LEVEL-TWO",
        base_path: "/imported-topic/topic/level-one/level-two",
        publication_state: "draft",
      },
    )

    publishing_api_has_item(taxon_attributes)
    publishing_api_has_expanded_links(taxon_attributes.slice(:content_id))
    stub_any_publishing_api_put_content

    expect {
      rake "taxonomy:validate_taxons_base_paths", "and_fix"
    }.to output(<<~LOG).to_stdout_from_any_process
      ✅ /level-one
      ❌    ├── /imported-topic/topic/level-one/level-two
      ------------------------------------
      The following taxons did not match the taxon URL structure. Attempting to fix this...
      CONTENT-ID-LEVEL-TWO /imported-topic/topic/level-one/level-two
        └─ /level-one/level-one-level-two
    LOG

    assert_publishing_api_put_content(
      taxon_attributes["content_id"],
      request_json_includes(base_path: "/level-one/level-one-level-two"),
    )
  end

  it "skips automatic fix for level one taxons" do
    content_store_has_tree_with_invalid_level_one_base_path

    expect {
      rake "taxonomy:validate_taxons_base_paths", "and_fix"
    }.to output(<<~LOG).to_stdout_from_any_process
      ❌ /level-one/taxon
      ✅    ├── /level-one/level-two
      ------------------------------------
      The following taxons did not match the taxon URL structure. Attempting to fix this...
      CONTENT-ID-LEVEL-ONE /level-one/taxon: skipping
    LOG
  end

  it "captures errors that might occur during updates" do
    content_store_has_tree_with_invalid_level_one_prefix

    taxon_attributes = taxon_with_details(
      "Level Two",
      other_fields: {
        content_id: "CONTENT-ID-LEVEL-TWO",
        base_path: "/some-other-path/level-two",
        publication_state: "draft",
      },
    )

    publishing_api_has_item(taxon_attributes)
    publishing_api_has_expanded_links(taxon_attributes.slice(:content_id))
    stub_any_publishing_api_put_content
      .to_return(status: 422, body:
        {
          error: {
            code: 422,
            message: "base path=/transport conflicts with content_id=a4038b29-b332-4f13-98b1-1c9709e216bc and locale=en",
            fields: {
              base: [
                "base path=/transport conflicts with content_id=a4038b29-b332-4f13-98b1-1c9709e216bc and locale=en",
              ],
            },
          },
        }.to_json)

    expect {
      travel_to "2018-02-28T16:23:32+00:00" do
        rake "taxonomy:validate_taxons_base_paths", "and_fix"
      end
    }.to output(<<~LOG).to_stdout_from_any_process
      ✅ /level-one
      ❌    ├── /some-other-path/level-two
      ------------------------------------
      The following taxons did not match the taxon URL structure. Attempting to fix this...
      CONTENT-ID-LEVEL-TWO /some-other-path/level-two: #<GdsApi::HTTPUnprocessableEntity: URL: https://publishing-api.test.gov.uk/v2/content/CONTENT-ID-LEVEL-TWO
      Response body:
      {"error":{"code":422,"message":"base path=/transport conflicts with content_id=a4038b29-b332-4f13-98b1-1c9709e216bc and locale=en","fields":{"base":["base path=/transport conflicts with content_id=a4038b29-b332-4f13-98b1-1c9709e216bc and locale=en"]}}}

      Request body:
      {:base_path=>"/level-one/level-two", :document_type=>"taxon", :schema_name=>"taxon", :title=>"Level Two", :publishing_app=>"content-tagger", :rendering_app=>"collections", :public_updated_at=>"2018-02-28T16:23:32+00:00", :locale=>"en", :details=>{:internal_name=>"internal name for Level Two", :notes_for_editors=>"Editor notes for Level Two", :visible_to_departmental_editors=>false}, :routes=>[{:path=>"/level-one/level-two", :type=>"exact"}], :update_type=>"major", :phase=>"live", :description=>"..."}>
    LOG
  end

  # /level-one
  #   /level-one/level-two
  def content_store_has_valid_two_level_tree
    content_store_has_item(
      "/",
      {
        "base_path" => "/",
        "content_id" => "CONTENT-ID-ROOT",
        "title" => "Root",
        "links" => {
          "level_one_taxons" => [
            {
              "base_path" => "/level-one",
              "content_id" => "CONTENT-ID-LEVEL-ONE",
              "title" => "Level One",
            },
          ],
        },
      }.to_json, draft: true
    )

    content_store_has_item(
      "/level-one",
      {
        "base_path" => "/level-one",
        "content_id" => "CONTENT-ID-LEVEL-ONE",
        "title" => "Level One",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/level-one/level-two",
              "content_id" => "CONTENT-ID-LEVEL-TWO",
              "title" => "Level Two",
              "links" => {},
            },
          ],
        },
      }.to_json, draft: true
    )

    content_store_has_item(
      "/level-one/level-two",
      {
        "base_path" => "/level-one/level-two",
        "content_id" => "CONTENT-ID-LEVEL-TWO",
        "title" => "Level Two",
        "links" => {},
      }.to_json, draft: true
    )
  end

  # /level-one
  #   /some-other-path/level-two
  def content_store_has_tree_with_invalid_level_one_prefix
    content_store_has_item(
      "/",
      {
        "base_path" => "/",
        "content_id" => "CONTENT-ID-ROOT",
        "title" => "Root",
        "links" => {
          "level_one_taxons" => [
            {
              "base_path" => "/level-one",
              "content_id" => "CONTENT-ID-LEVEL-ONE",
              "title" => "Level One",
            },
          ],
        },
      }.to_json, draft: true
    )

    content_store_has_item(
      "/level-one",
      {
        "base_path" => "/level-one",
        "content_id" => "CONTENT-ID-LEVEL-ONE",
        "title" => "Level One",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/some-other-path/level-two",
              "content_id" => "CONTENT-ID-LEVEL-TWO",
              "title" => "Level Two",
              "links" => {},
            },
          ],
        },
      }.to_json, draft: true
    )

    content_store_has_item(
      "/some-other-path/level-two",
      {
        "base_path" => "/some-other-path/level-two",
        "content_id" => "CONTENT-ID-LEVEL-TWO",
        "title" => "Level Two",
        "links" => {},
      }.to_json, draft: true
    )
  end

  # /level-one
  #   /imported-topic/topic/level-one/level-two
  def content_store_has_tree_with_long_base_path_structure
    content_store_has_item(
      "/",
      {
        "base_path" => "/",
        "content_id" => "CONTENT-ID-ROOT",
        "title" => "Root",
        "links" => {
          "level_one_taxons" => [
            {
              "base_path" => "/level-one",
              "content_id" => "CONTENT-ID-LEVEL-ONE",
              "title" => "Level One",
            },
          ],
        },
      }.to_json, draft: true
    )

    content_store_has_item(
      "/level-one",
      {
        "base_path" => "/level-one",
        "content_id" => "CONTENT-ID-LEVEL-ONE",
        "title" => "Level One",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/imported-topic/topic/level-one/level-two",
              "content_id" => "CONTENT-ID-LEVEL-TWO",
              "title" => "Level Two",
              "links" => {},
            },
          ],
        },
      }.to_json, draft: true
    )

    content_store_has_item(
      "/imported-topic/topic/level-one/level-two",
      {
        "base_path" => "/imported-topic/topic/level-one/level-two",
        "content_id" => "CONTENT-ID-LEVEL-TWO",
        "title" => "Level Two",
        "links" => {},
      }.to_json, draft: true
    )
  end

  # /level-one/taxon
  #   /level-one/level-two
  def content_store_has_tree_with_invalid_level_one_base_path
    content_store_has_item(
      "/",
      {
        "base_path" => "/",
        "content_id" => "CONTENT-ID-ROOT",
        "title" => "Root",
        "links" => {
          "level_one_taxons" => [
            {
              "base_path" => "/level-one/taxon",
              "content_id" => "CONTENT-ID-LEVEL-ONE",
              "title" => "Level One",
            },
          ],
        },
      }.to_json, draft: true
    )

    content_store_has_item(
      "/level-one/taxon",
      {
        "base_path" => "/level-one/taxon",
        "content_id" => "CONTENT-ID-LEVEL-ONE",
        "title" => "Level One",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/level-one/level-two",
              "content_id" => "CONTENT-ID-LEVEL-TWO",
              "title" => "Level Two",
              "links" => {},
            },
          ],
        },
      }.to_json, draft: true
    )

    content_store_has_item(
      "/level-one/level-two",
      {
        "base_path" => "/level-one/level-two",
        "content_id" => "CONTENT-ID-LEVEL-TWO",
        "title" => "Level Two",
        "links" => {},
      }.to_json, draft: true
    )
  end
end

# rubocop:enable Style/BlockDelimiters
