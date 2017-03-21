require "rails_helper"

RSpec.feature "Draft taxonomy" do
  include PublishingApiHelper
  include ContentItemHelper

  scenario "User can see draft taxons" do
    given_there_are_draft_taxons
    when_i_visit_the_draft_taxonomy_page
    then_i_can_see_the_draft_taxons
  end

  def given_there_are_draft_taxons
    @taxon_1 = content_item_with_details(
      "I Am A Taxon 1",
      other_fields: {
        content_id: "ID-1",
        base_path: "/foo",
        publication_state: 'active'
      }
    )
    @taxon_2 = content_item_with_details(
      "I Am Another Taxon 2",
      other_fields: {
        content_id: "ID-2",
        base_path: "/bar",
        publication_state: 'active'
      }
    )
    @taxon_3 = content_item_with_details(
      "I Am Yet Another Taxon 3",
      other_fields: {
        content_id: "ID-3",
        base_path: "/bar",
        publication_state: 'active'
      }
    )

    publishing_api_has_taxons(
      [@taxon_1, @taxon_2, @taxon_3],
      page: 1,
      states: ["draft"]
    )
  end

  def when_i_visit_the_draft_taxonomy_page
    visit drafts_taxons_path
  end

  def then_i_can_see_the_draft_taxons
    expect(page).to have_text(@taxon_1[:title])
    expect(page).to have_text(@taxon_2[:title])
    expect(page).to have_text(@taxon_3[:title])
  end
end
