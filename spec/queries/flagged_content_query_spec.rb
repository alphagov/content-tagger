require "rails_helper"

RSpec.describe FlaggedContentQuery do
  describe "#items" do
    let(:project) { create(:project) }
    let!(:item_needs_help) do
      create(
        :project_content_item,
        :flagged_needs_help,
        project:,
      )
    end
    let!(:item_missing_topic) do
      create(
        :project_content_item,
        :flagged_missing_topic,
        project:,
        suggested_tags: "Better Taxon Suggestion",
      )
    end
    let!(:item_missing_topic_with_missing_suggested_tag) do
      create(
        :project_content_item,
        :flagged_missing_topic,
        project:,
        suggested_tags: "",
      )
    end

    context "when querying for content items flagged with needs help" do
      it "returns the flagged content items" do
        params = {
          flagged: "needs_help",
          taxonomy_branch: project.taxonomy_branch,
        }

        expect(FlaggedContentQuery.new(params).items).to include(item_needs_help)
      end
    end

    context "when querying for content items flagged with missing topic" do
      it "returns the flagged content items with suggested tags" do
        params = {
          flagged: "missing_topic",
          taxonomy_branch: project.taxonomy_branch,
        }

        expect(FlaggedContentQuery.new(params).items).to include(item_missing_topic)
      end

      it "does not return content items with missing suggested tags" do
        params = {
          flagged: "missing_topic",
          taxonomy_branch: project.taxonomy_branch,
        }

        expect(FlaggedContentQuery.new(params).items).to_not include(item_missing_topic_with_missing_suggested_tag)
      end
    end
  end
end
