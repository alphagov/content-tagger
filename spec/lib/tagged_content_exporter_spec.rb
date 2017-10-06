require "rails_helper"
require_relative "../../lib/tagged_content_exporter"

RSpec.describe TaggedContentExporter do
  describe "#content_items_with_taxons" do
    it "returns the content_items" do
      create(:user,
             uid: "user-1234",
             organisation_slug: "department-for-transport")

      project = create(:project, taxonomy_branch: "a4038b29-b332-4f13-98b1-1c9709e216bc")

      create(:project_content_item,
             done: true,
             project: project,
             content_id: "1b99def9-7eaa-4fb4-a0d0-ea76f0c5c370",
             url: "https://www.test.gov.uk/government/publications/great-western-franchise-2013")

      publishing_api_has_links(
        content_id: "1b99def9-7eaa-4fb4-a0d0-ea76f0c5c370",
        links: {
          taxons: [
            "taxn-1234"
          ]
        }
      )

      stub_request(:get, "https://publishing-api.test.gov.uk/v2/links/changes?link_types%5B%5D=taxons&source_content_ids%5B%5D=1b99def9-7eaa-4fb4-a0d0-ea76f0c5c370")
        .to_return(body: {
          "link_changes" => [
            {
              "source" => {
                "title" => "Great Western rail franchise 2011 and 2012: competition documentation",
                "base_path" => "/government/publications/great-western-franchise-2013",
                "content_id" => "1b99def9-7eaa-4fb4-a0d0-ea76f0c5c370"
              },
              "target" => {
                "title" => "Rail procurement documents",
                "base_path" => "/transport/rail-procurement-documents",
                "content_id" => "taxn-1234"
              },
              "link_type" => "taxons",
              "change" => "add",
              "user_uid" => "user-1234",
            }
          ]
        }.to_json)

      publishing_api_has_expanded_links(
        "content_id" => "taxn-1234",
        "expanded_links" => {
          "parent_taxons" => [
            {
              "content_id" => "taxn-prnt-9876",
              "links" => {},
            }
          ]
        }
      )

      expected_content_items = [
        {
          content_id: "1b99def9-7eaa-4fb4-a0d0-ea76f0c5c370",
          url: "/government/publications/great-western-franchise-2013",
          taxons: [
            {
              content_id: "taxn-1234",
              depth: 1,
              url: "/transport/rail-procurement-documents",
              user_uid: "user-1234",
              organisation_slug: "department-for-transport",
            }
          ],
        }
      ]

      content_items = TaggedContentExporter.new.content_items_with_taxons
      expect(content_items). to eq(expected_content_items)
    end
  end
end
