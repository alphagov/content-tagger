module TaxonomyHelper
  def draft_taxon_title
    "Test Taxon"
  end

  def valid_taxon_uuid
    "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
  end

  def invalid_taxon_uuid
    "nope"
  end

  def stub_draft_taxonomy_branch
    root_content_id = GovukTaxonomy::ROOT_CONTENT_ID

    draft_level_one_taxons = {
      "level_one_taxons" => [
        {
          "content_id" => valid_taxon_uuid,
          "title" => draft_taxon_title,
        },
      ],
    }

    root_taxon_content = {
      "title" => draft_taxon_title,
      "base_path" => "/foo",
      "content_id" => valid_taxon_uuid,
    }

    root_taxon_expanded_links = {}

    stub_publishing_api_has_expanded_links({ content_id: root_content_id }, with_drafts: false)
    stub_publishing_api_has_expanded_links({ content_id: root_content_id, expanded_links: draft_level_one_taxons })
    stub_publishing_api_has_item(root_taxon_content)
    stub_publishing_api_has_expanded_links({ content_id: valid_taxon_uuid, expanded_links: root_taxon_expanded_links })
  end

  def stub_tag_content(content_id, success: true)
    stub_request(:patch, "https://publishing-api.test.gov.uk/v2/links/#{content_id}")
      .to_return(status: success ? 200 : 400)
  end

  def stub_organisation_tagging_progress
    stub_request(:get, search_api_url_for_all_document_counts_url)
      .to_return(body: all_document_counts_response.to_json)

    stub_request(:get, search_api_url_for_tagged_document_counts_url)
      .to_return(body: tagged_documents_counts_response.to_json)
  end

private

  def search_api_url_for_all_document_counts_url
    "https://search-api.test.gov.uk/search.json?aggregate_primary_publishing_organisation=0,scope:all_filters&count=0&filter_primary_publishing_organisation%5B%5D=department-for-transport&filter_primary_publishing_organisation%5B%5D=high-speed-two-limited&filter_primary_publishing_organisation%5B%5D=home-office&filter_primary_publishing_organisation%5B%5D=maritime-and-coastguard-agency&start=0"
  end

  def all_document_counts_response
    {
      "results" => [],
      "total" => 15_235,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [
            { "value" => { "slug" => "home-office" }, "documents" => 7475 },
            { "value" => { "slug" => "department-for-transport" }, "documents" => 5844 },
            { "value" => { "slug" => "maritime-and-coastguard-agency" }, "documents" => 0 },
            { "value" => { "slug" => "high-speed-two-limited" }, "documents" => 753 },
          ],
          "documents_with_no_value" => 0,
          "total_options" => 4,
          "missing_options" => 4,
          "scope" => "all_filters",
        },
      },
      "suggested_queries" => [],
    }
  end

  def search_api_url_for_tagged_document_counts_url
    "https://search-api.test.gov.uk/search.json?aggregate_primary_publishing_organisation=0,scope:all_filters&count=0&filter_part_of_taxonomy_tree%5B%5D=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa&filter_primary_publishing_organisation%5B%5D=department-for-transport&filter_primary_publishing_organisation%5B%5D=high-speed-two-limited&filter_primary_publishing_organisation%5B%5D=home-office&filter_primary_publishing_organisation%5B%5D=maritime-and-coastguard-agency&start=0"
  end

  def tagged_documents_counts_response
    {
      "results" => [],
      "total" => 2490,
      "start" => 0,
      "aggregates" => {
        "primary_publishing_organisation" => {
          "options" => [
            { "value" => { "slug" => "home-office" }, "documents" => 0 },
            { "value" => { "slug" => "department-for-transport" }, "documents" => 1072 },
            { "value" => { "slug" => "maritime-and-coastguard-agency" }, "documents" => 0 },
            { "value" => { "slug" => "high-speed-two-limited" }, "documents" => 744 },
          ],
          "documents_with_no_value" => 0,
          "total_options" => 4,
          "missing_options" => 4,
          "scope" => "all_filters",
        },
      },
      "suggested_queries" => [],
    }
  end
end
