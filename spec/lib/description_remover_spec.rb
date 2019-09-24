require "rails_helper"
require "description_remover"
require "gds_api/test_helpers/content_store"

include ::GdsApi::TestHelpers::ContentStore
include ::GdsApi::TestHelpers::PublishingApiV2

RSpec.describe DescriptionRemover do
  context "appropriate taxons are updated" do
    before do
      content_store_has_item("/work", taxon.to_json, draft: true)
      publishing_api_has_item(published_child_taxon)
      publishing_api_has_item(published_child_taxon_with_draft)
      publishing_api_has_item(draft_taxon)

      stub_any_publishing_api_put_content
      stub_any_publishing_api_publish

      DescriptionRemover.call("/work")
    end

    it "asserts taxon has draft saved and published" do
      assert_put_content("pub-taxon", content_id: "pub-taxon", title: "taxon-a", phase: "live", base_path: "/work/taxon_a")
      assert_publishing_api_publish("pub-taxon")
    end

    it "asserts taxon is not saved or published as it has a draft" do
      assert_no_put_content("pub-and-draft-taxon")
      assert_no_publish("pub-and-draft-taxon")
    end

    it "asserts taxon is not published as it is only a draft" do
      assert_no_put_content("draft-taxon")
      assert_no_publish("draft-taxon")
    end
  end

  def taxon
    {
      "base_path" => "/work",
      "content_id" => "rrrr",
      "links" => {
        "child_taxons" => [
          published_child_taxon,
          published_child_taxon_with_draft,
          draft_taxon,
        ],
      },
    }
  end

  def published_child_taxon
    {
      "schema_name" => "taxon",
      "content_store" => "live",
      "user_facing_version" => "4",
      "publication_state" => "published",
      "lock_version" => "3",
      "updated_at" => Time.now,
      "phase" => "live",
      "title" => "taxon-a",
      "description" => "taxons-a-description",
      "base_path" => "/work/taxon_a",
      "content_id" => "pub-taxon",
      "state_history" => {
        "1" => "superseded",
        "2" => "published",
      },
    }
  end

  def published_child_taxon_with_draft
    {
      "schema_name" => "taxon",
      "content_store" => "live",
      "user_facing_version" => "4",
      "publication_state" => "published",
      "lock_version" => "3",
      "updated_at" => Time.now,
      "phase" => "live",
      "title" => "taxon-b",
      "base_path" => "/work/taxon_b",
      "content_id" => "pub-and-draft-taxon",
      "state_history" => {
        "1" => "published",
        "2" => "draft",
      },
    }
  end

  def draft_taxon
    {
      "schema_name" => "taxon",
      "content_store" => "draft",
      "user_facing_version" => "4",
      "publication_state" => "draft",
      "lock_version" => "3",
      "updated_at" => Time.now,
      "phase" => "live",
      "title" => "taxon-c",
      "base_path" => "/work/taxon_c",
      "content_id" => "draft-taxon",
      "state_history" => {
        "1" => "draft",
      },
    }
  end

  def assert_put_content(content_id, params)
    param_defaults = {
      description: nil,
      schema_name: "taxon",
      update_type: "minor",
    }
    assert_publishing_api_put_content(content_id, param_defaults.merge(params), 1)
  end

  def assert_no_put_content(content_id)
    assert_publishing_api_put_content(content_id, nil, 0)
  end

  def assert_no_publish(content_id)
    assert_publishing_api_publish(content_id, nil, 0)
  end
end
