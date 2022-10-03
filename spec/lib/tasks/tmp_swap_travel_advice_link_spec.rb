require "rails_helper"

RSpec.describe "travel_advice:crisis_support" do
  include PublishingApiHelper
  include RakeTaskHelper

  before do
    stub_any_publishing_api_patch_links
  end

  context "content item has links we want to swap" do
    let(:edition) do
      {
        content_id: SecureRandom.uuid,
        document_type: "travel_advice",
        publishing_app: "travel-advice-publisher",
        links: {
          ordered_related_items: %w[
            850ce029-b884-4c1f-8410-7f8fe7e49426
            98c68202-8c31-405c-b2dc-ad3c00eda687
            5dc09a0e-7631-11e4-a3cb-005056011aef
          ],
        },
      }
    end

    before do
      stub_publishing_api_get_editions(
        [edition],
        per_page: 300,
        publishing_app: "travel-advice-publisher",
        document_types: %w[travel_advice],
        states: %w[published],
      )

      stub_publishing_api_has_links(
        {
          content_id: edition[:content_id],
          links: edition[:links],
        },
      )
    end

    it "swaps /guidance/how-to-deal-with-a-crisis-overseas for /government/collections/support-for-british-nationals-abroad" do
      rake "travel_advice:crisis_support"

      assert_publishing_api_patch_links(
        edition[:content_id],
        links: {
          "ordered_related_items" => %w[
            850ce029-b884-4c1f-8410-7f8fe7e49426
            98c68202-8c31-405c-b2dc-ad3c00eda687
            aad65646-964d-4f68-ac22-5bc6c8281336
          ],
        },
        bulk_publishing: true,
      )
    end

    it "doesn't swap in that link for other content types" do
      edition[:document_type] = "publication"

      rake "travel_advice:crisis_support"

      refute(assert_publishing_api_patch_links(
               edition[:content_id],
               links: {
                 "ordered_related_items" => %w[
                   850ce029-b884-4c1f-8410-7f8fe7e49426
                   98c68202-8c31-405c-b2dc-ad3c00eda687
                   aad65646-964d-4f68-ac22-5bc6c8281336
                 ],
               },
               bulk_publishing: true,
             ))
    end
  end

  context "another item doesn't have any links" do
    let(:no_links_edition) do
      {
        content_id: SecureRandom.uuid,
        document_type: "travel_advice",
        publishing_app: "travel-advice-publisher",
      }
    end

    before do
      stub_publishing_api_get_editions(
        [no_links_edition],
        per_page: 300,
        publishing_app: "travel-advice-publisher",
        document_types: %w[travel_advice],
        states: %w[published],
      )

      stub_publishing_api_has_links(
        {
          content_id: no_links_edition[:content_id],
          links: no_links_edition[:links],
        },
      )
    end

    it "skips updating links for content item that doesn't have links" do
      assert no_links_edition["links"].nil?

      rake "travel_advice:crisis_support"

      assert no_links_edition["links"].nil?
    end
  end

  context "another item has links but no ordered_related_items" do
    let(:no_ordered_related_items_edition) do
      {
        content_id: SecureRandom.uuid,
        document_type: "travel_advice",
        publishing_app: "travel-advice-publisher",
        links: {
          "suggested_ordered_related_items" => %w[
            850ce029-b884-4c1f-8410-7f8fe7e49426
            98c68202-8c31-405c-b2dc-ad3c00eda687
          ],
        },
      }
    end

    before do
      stub_publishing_api_get_editions(
        [no_ordered_related_items_edition],
        per_page: 300,
        publishing_app: "travel-advice-publisher",
        document_types: %w[travel_advice],
        states: %w[published],
      )

      stub_publishing_api_has_links(
        {
          content_id: no_ordered_related_items_edition[:content_id],
          links: no_ordered_related_items_edition[:links],
        },
      )
    end

    it "skips updating links for content item that doesn't have ordered_related_items" do
      expect(no_ordered_related_items_edition[:links]).to_not include("ordered_related_items")

      rake "travel_advice:crisis_support"

      expect(no_ordered_related_items_edition[:links]).to_not include("ordered_related_items")
    end
  end
end
