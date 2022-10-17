require "gds_api/test_helpers/search"

RSpec.describe "govuk:export_content_by_organisations", type: :task do
  include RakeTaskHelper
  include ::GdsApi::TestHelpers::Search

  before :each do
    stub_any_search.to_return(body: { "results" => [{ "content_id" => "1b99def9-7eaa-4fb4-a0d0-ea76f0c5c370",
                                                      "primary_publishing_organisation" => "department-for-transport",
                                                      "organisations" => [{
                                                        "slug" => "department-for-transport",
                                                      }] }] }.to_json)
  end

  it "creates a file" do
    create(
      :user,
      uid: "user-1234",
      organisation_slug: "department-for-transport",
    )

    project = create(:project, taxonomy_branch: "a4038b29-b332-4f13-98b1-1c9709e216bc")

    create(
      :project_content_item,
      project:,
      content_id: "1b99def9-7eaa-4fb4-a0d0-ea76f0c5c370",
      url: "https://www.gov.uk/government/publications/great-western-franchise-2013",
    )

    FakeFS do
      rake("govuk:export_content_by_organisations", "department-for-transport")
      expect(open("department-for-transport.csv").read.length).to be > 0
    end
  end
end
