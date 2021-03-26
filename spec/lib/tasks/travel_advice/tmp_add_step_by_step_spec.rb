require "rails_helper"

RSpec.describe "travel_advice:add_step_by_step" do
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

  it "adds a link in the second position of ordered_related_items for travel advice" do
    rake "travel_advice:add_step_by_step"

    assert_publishing_api_patch_links(
      edition[:content_id],
      links: {
        "ordered_related_items" => %w[
          850ce029-b884-4c1f-8410-7f8fe7e49426
          8c0c7b83-5e0b-4bed-9121-1c394e2f96f3
          98c68202-8c31-405c-b2dc-ad3c00eda687
        ],
      },
      bulk_publishing: true,
    )
  end

  it "does not add a link in the second position of ordered_related_items for other content types" do
    edition[:document_type] = "publication"

    rake "travel_advice:add_step_by_step"

    refute(assert_publishing_api_patch_links(
             edition[:content_id],
             links: {
               "ordered_related_items" => %w[
                 850ce029-b884-4c1f-8410-7f8fe7e49426
                 8c0c7b83-5e0b-4bed-9121-1c394e2f96f3
                 98c68202-8c31-405c-b2dc-ad3c00eda687
               ],
             },
             bulk_publishing: true,
           ))
  end
end
