RSpec.describe ProjectBuilder do
  let(:project_name) { "project_name" }
  let(:taxonomy_branch_content_id) { SecureRandom.uuid }
  let(:content_item_attributes) { [] }
  let(:bulk_tagging_enabled) { false }

  def build_project(
    name: project_name,
    branch: taxonomy_branch_content_id,
    content_items: content_item_attributes,
    bulk_tagging: bulk_tagging_enabled
  )
    ProjectBuilder.call(
      content_item_attributes: content_items,
      project_attributes: {
        name:,
        taxonomy_branch: branch,
        bulk_tagging_enabled: bulk_tagging,
      },
    )
  end

  describe ".call" do
    it "creates a new project" do
      stub_publishing_api_has_lookups({})

      expect { build_project }.to change(Project, :count).by(1)
    end

    it "creates new project content items" do
      stub_publishing_api_has_lookups(
        "/url_one" => SecureRandom.uuid,
        "/url_two" => SecureRandom.uuid,
      )

      expect { build_project(content_items: [{ url: "https://www.gov.uk/url_one" }, { url: "https://www.gov.uk/url_two" }]) }
        .to change(ProjectContentItem, :count).by(2)
    end

    it "finds the content items' IDs from the Publishing API" do
      stub_publishing_api_has_lookups("/url_one" => "cbccfe81-8cff-4e0f-ad6f-d3631623a9a7")

      expect { build_project(content_items: [{ url: "https://www.gov.uk/url_one" }]) }
        .to change(ProjectContentItem, :count).by(1)

      expect(ProjectContentItem.last.content_id).to eq("cbccfe81-8cff-4e0f-ad6f-d3631623a9a7")
    end

    it "raises an error when an unknown attribute type is given to ProjectContentItems" do
      expect { build_project(content_items: [{ foo: "bar" }]) }
        .to raise_error ActiveModel::UnknownAttributeError
    end

    it "raises an error and rollbacks the transaction when attempting to import duplicate content" do
      create(:project_content_item, content_id: "cbccfe81-8cff-4e0f-ad6f-d3631623a9a7")

      stub_publishing_api_has_lookups("/url_one" => "cbccfe81-8cff-4e0f-ad6f-d3631623a9a7")

      expect(Project.count).to eq(0)
      expect(ProjectContentItem.count).to eq(1)

      expect { build_project(content_items: [{ url: "https://www.gov.uk/url_one" }]) }
        .to raise_error ProjectBuilder::DuplicateContentItemsError

      expect(Project.count).to eq(0)
      expect(ProjectContentItem.count).to eq(1)
    end
  end
end
