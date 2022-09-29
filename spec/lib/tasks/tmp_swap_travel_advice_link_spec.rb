require "rails_helper"

RSpec.describe "travel_advice:crisis_support" do
  include PublishingApiHelper
  include RakeTaskHelper

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

    stub_any_publishing_api_patch_links
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
