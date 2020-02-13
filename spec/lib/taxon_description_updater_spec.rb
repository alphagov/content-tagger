require "rails_helper"
require "taxon_description_updater"

RSpec.describe TaxonDescriptionUpdater do
  let(:with_dots) do
    [
      create_taxon("content_id" => "desc-...", "title" => "title ...", "description" => "..."),
      create_taxon(
        "content_id" => "desc-...-draft",
        "title" => "title ...",
        "description" => "...",
        "state_history" => {
          1 => "superseded",
          2 => "published",
          3 => "draft",
        },
      ),
      create_taxon("content_id" => "desc-other", "title" => "title other", "description" => "other..."),
    ]
  end
  let(:with_tbc) do
    [
      create_taxon("content_id" => "desc-tbc", "title" => "title2 ...", "description" => "tbc", "phase" => "beta"),
      create_taxon(
        "content_id" => "desc-tbc-draft",
        "title" => "title2 ...",
        "description" => "tbc",
        "state_history" => {
          1 => "published",
          2 => "draft",
        },
      ),
      create_taxon("content_id" => "desc-other-tbc", "title" => "title2 other", "description" => "other tbc"),
      create_taxon(
        "content_id" => "desc-tbc-pub",
        "title" => "title2 ...",
        "publication_state" => "published",
        "description" => "tbc",
        "state_history" => {
          1 => "published",
          2 => "draft",
        },
      ),
    ]
  end

  before do
    stub_publishing_api_has_content(with_dots, per_page: 5000, q: "...", search_in: %w[description], states: %w[published draft])
    stub_publishing_api_has_content(with_tbc, per_page: 5000, q: "tbc", search_in: %w[description], states: %w[published draft])
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish

    TaxonDescriptionUpdater.new(%w[... tbc]).call
  end

  it "updated the published ... editions correctly" do
    assert_put_content("desc-...", content_id: "desc-...", title: "title ...", phase: "live")
    assert_publish "desc-..."
    assert_no_put_content("desc-other")
    assert_no_publish("desc-other")
  end

  it "updated the published tbc editions correctly" do
    assert_put_content("desc-tbc", content_id: "desc-tbc", title: "title2 ...", phase: "beta")
    assert_publish "desc-tbc"
    assert_no_put_content("desc-other-tbc")
    assert_no_publish("desc-other-tbc")
  end

  it "updated the draft editions but did not publish" do
    assert_put_content("desc-...-draft", content_id: "desc-...-draft", title: "title ...", phase: "live")
    assert_no_publish "desc-...-draft"
    assert_put_content("desc-tbc-draft", content_id: "desc-tbc-draft", title: "title2 ...", phase: "live")
    assert_no_publish "desc-tbc-draft"
  end

  it "doesnt update the edition as there is a published and draft edition present" do
    assert_no_put_content("desc-tbc-pub")
    assert_no_publish("desc-tbc-pub")
  end

private

  def create_taxon(attributes)
    {
      "schema_name" => "taxon",
      "content_store" => "live",
      "user_facing_version" => 4,
      "publication_state" => "draft",
      "lock_version" => 3,
      "updated_at" => Time.zone.now,
      "phase" => "live",
      "state_history" => {
        1 => "superseded",
        2 => "published",
      },
    }.merge(attributes)
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

  def assert_publish(content_id)
    assert_publishing_api_publish content_id
  end

  def assert_no_publish(content_id)
    assert_publishing_api_publish content_id, nil, 0
  end
end
