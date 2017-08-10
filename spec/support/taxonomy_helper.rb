module TaxonomyHelper
  def draft_taxon_title
    'Test Taxon'
  end

  def valid_taxon_uuid
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
  end

  def invalid_taxon_uuid
    'nope'
  end

  def stub_draft_taxonomy_branch
    content_id = GovukTaxonomy::Branches::HOMEPAGE_CONTENT_ID

    draft_root_taxons = {
      'root_taxons' => [
        {
          'content_id' => valid_taxon_uuid,
          'title' => draft_taxon_title
        }
      ]
    }

    root_taxon_content = {
      'title' => draft_taxon_title,
      'base_path' => '/foo',
      'content_id' => valid_taxon_uuid
    }

    root_taxon_expanded_links = {}

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/#{content_id}?with_drafts=false")
      .to_return(status: 200, body: {}.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/#{content_id}")
      .to_return(status: 200, body: { expanded_links: draft_root_taxons }.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/#{valid_taxon_uuid}")
      .to_return(status: 200, body: root_taxon_content.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/#{valid_taxon_uuid}")
      .to_return(status: 200, body: root_taxon_expanded_links.to_json)
  end

  def stub_tag_content(content_id, success: true)
    stub_request(:patch, "https://publishing-api.test.gov.uk/v2/links/#{content_id}")
      .to_return(status: success ? 200 : 400)
  end
end
