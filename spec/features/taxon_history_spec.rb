require "rails_helper"

RSpec.feature "Taxon history", type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

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
      content_id = SecureRandom.uuid
      taxon = content_item_with_details("foo", other_fields: { content_id: content_id })
      stub_requests_for_show_page(taxon)
      build(:taxon, content_id: content_id)
    end
  end
end
