require "rails_helper"

RSpec.feature "Taxon history", type: :feature do
  include ContentItemHelper

  scenario "deleting a taxon with no children or tagged content" do
    given_taxon_with_some_tagging_events
    when_i_visit_the_taxon_page
    and_i_click_taxon_history_button
    then_i_see_a_table_of_related_tagging_events
  end

  def given_taxon_with_some_tagging_events
    @tagging_events = [
      create(:tagging_event, taxon_content_id: taxon.content_id),
      create(:tagging_event, taxon_content_id: taxon.content_id)
    ]
  end

  def when_i_visit_the_taxon_page
    visit taxon_path(taxon.content_id)
  end

  def and_i_click_taxon_history_button
    click_link "Taxon history"
  end

  def then_i_see_a_table_of_related_tagging_events
    table = find('table')
    table_head = table.all('thead th').map(&:text)
    table_body = table.find('tbody').text

    expect(table_head).to include(/Date/i)
    expect(table_head).to include(/Page/i)
    expect(table_head).to include(/User/i)

    expect(table_body).to include(@tagging_events[0].taggable_title)
    expect(table_body).to include(@tagging_events[1].taggable_title)
  end

  def taxon
    @_taxon ||= begin
      id = SecureRandom.uuid

      publishing_api_has_item content_item_with_details(
        "blah",
        other_fields: { content_id: id }
      )

      publishing_api_has_links(
        content_id: id,
        links: {}
      )

      publishing_api_has_expanded_links(
        content_id: id,
        expanded_links: {}
      )
      publishing_api_has_linked_items(
        [],
        content_id: id,
        link_type: "taxons"
      )

      build(:taxon, content_id: id)
    end
  end
end
