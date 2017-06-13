require "rails_helper"

RSpec.feature "Analytics index", type: :feature do
  scenario "Viewing the index page" do
    given_some_tagging_events
    when_i_visit_the_analytics_page
    then_i_should_see_the_name_of_the_taxon
    and_the_count_of_its_tagged_content
  end

  def given_some_tagging_events
    id = SecureRandom.uuid
    create(:tagging_event, taxon_content_id: id, taxon_title: taxon_title)
    create(:tagging_event, taxon_content_id: id, taxon_title: taxon_title)
  end

  def when_i_visit_the_analytics_page
    visit analytics_path
  end

  def then_i_should_see_the_name_of_the_taxon
    expect(table_contents).to include(taxon_title)
  end

  def and_the_count_of_its_tagged_content
    expect(table_contents).to include(TaggingEvent.all.count.to_s)
  end

  def table_contents
    find('table').text
  end

  def taxon_title
    "I am a taxon, from taxonia."
  end
end
