require 'rails_helper'

RSpec.feature "Projects", type: :feature do
  include RemoteCsvHelper
  include TaxonomyHelper

  scenario "viewing a project" do
    given_there_is_a_project_with_content_items
    and_there_is_a_draft_taxonomy_branch
    when_i_visit_the_project_page
    then_i_can_see_all_the_content_items_for_that_project
  end

  scenario "creating a new project" do
    given_there_is_a_remote_spreadsheet
    and_there_is_a_draft_taxonomy_branch
    when_i_create_a_new_project
    when_i_visit_the_project_index_page
    then_i_can_see_my_new_project_in_the_list
  end

  scenario "filtering for tagged content items" do
    given_there_is_a_project_with_two_content_items_in_different_states
    and_there_is_a_draft_taxonomy_branch
    when_i_visit_the_project_page
    and_i_filter_by_tagged
    then_i_only_see_done_content_items
  end

  scenario "filtering for not tagged content items" do
    given_there_is_a_project_with_two_content_items_in_different_states
    and_there_is_a_draft_taxonomy_branch
    when_i_visit_the_project_page
    and_i_filter_by_not_tagged
    then_i_only_see_not_done_content_items
  end

  scenario "filtering for all content items" do
    given_there_is_a_project_with_two_content_items_in_different_states
    and_there_is_a_draft_taxonomy_branch
    when_i_visit_the_project_page
    and_i_filter_by_all
    then_i_can_see_all_the_content_items_for_that_project
  end

  def given_there_is_a_project_with_content_items
    @project = create :project, :with_content_items
  end

  def given_there_is_a_project_with_two_content_items_in_different_states
    @project = create :project
    @done_content_item = create(
      :project_content_item, title: "Foo", done: true, project_id: @project.id
    )
    @not_done_content_item = create(
      :project_content_item, title: "Bar", done: false, project_id: @project.id
    )
  end

  def given_there_is_a_remote_spreadsheet
    stub_remote_csv
  end

  def and_there_is_a_draft_taxonomy_branch
    stub_draft_taxonomy_branch
  end

  def when_i_create_a_new_project
    visit projects_path
    click_link 'Add new project'
    fill_in 'new_project_form_name', with: 'my_project'
    select draft_taxon_title, from: 'Branch of GOV.UK taxonomy'
    fill_in 'new_project_form_remote_url', with: 'http://www.example.com/my_csv'
    allow(LookupContentIdWorker).to receive(:perform_async)
    click_on 'New Project'
  end

  def when_i_visit_the_project_page
    visit root_path
    within 'header nav .nav' do
      click_link 'Projects'
    end
    click_link @project.name
  end

  def and_i_visit_the_project_index_page
    visit projects_path
  end
  alias_method :when_i_visit_the_project_index_page, :and_i_visit_the_project_index_page

  def and_i_filter_by_tagged
    within '.filter-controls' do
      choose("Tagged")
      click_button("Apply")
    end
  end

  def and_i_filter_by_not_tagged
    within '.filter-controls' do
      choose("Not Tagged")
      click_button("Apply")
    end
  end

  def and_i_filter_by_all
    within '.filter-controls' do
      choose("All")
      click_button("Apply")
    end
  end

  def then_i_can_see_my_new_project_in_the_list
    expect(page).to have_content 'my_project'
  end

  def then_i_can_see_all_the_content_items_for_that_project
    @project.content_items.each do |content_item|
      expect(page).to have_content content_item.title
    end
  end

  def then_i_only_see_done_content_items
    expect(page).to have_content @done_content_item.title
    expect(page).not_to have_content @not_done_content_item.title
  end

  def then_i_only_see_not_done_content_items
    expect(page).not_to have_content @done_content_item.title
    expect(page).to have_content @not_done_content_item.title
  end
end
