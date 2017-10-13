require 'rails_helper'

RSpec.describe 'Reporting missing taxons to the IA team' do
  include TaxonomyHelper

  scenario 'IAs can see flagged content items for a branch of the taxonomy' do
    given_i_am_logged_in_as_a_gds_editor
    and_there_is_a_draft_branch_of_the_taxonomy
    and_there_are_content_items_with_suggested_terms
    when_i_visit_the_projects_page
    and_i_click_the_see_commented_items_link
    then_i_can_see_the_suggested_terms
  end

  def given_i_am_logged_in_as_a_gds_editor
    login_as create(:user, :gds_editor)
  end

  def and_there_is_a_draft_branch_of_the_taxonomy
    stub_draft_taxonomy_branch
    stub_tagging_progress
  end

  def and_there_are_content_items_with_suggested_terms
    p1 = create(:project)
    p1.content_items << create(:project_content_item, :flagged_missing_topic, title: 'foo')
    p2 = create(:project)
    p2.content_items << create(:project_content_item, :flagged_missing_topic, title: 'bar')
  end

  def when_i_visit_the_projects_page
    visit '/projects'
  end

  def and_i_click_the_see_commented_items_link
    click_link "View suggested topics"
  end

  def then_i_can_see_the_suggested_terms
    expect(page).to have_content('foo')
    expect(page).to have_content('bar')
  end
end
