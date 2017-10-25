require 'rails_helper'

RSpec.feature "Projects", type: :feature do
  include RemoteCsvHelper
  include TaxonomyHelper
  include PublishingApiHelper

  scenario "viewing a project" do
    given_there_is_a_project_with_content_items
    when_i_visit_the_project_page
    then_i_can_see_todo_content_items_for_that_project
  end

  scenario "creating a new project" do
    given_there_is_a_remote_spreadsheet
    and_there_is_a_draft_taxonomy_branch
    when_i_create_a_new_project
    when_i_visit_the_project_index_page
    then_i_can_see_my_new_project_in_the_list
  end

  scenario "deleting an existing project" do
    given_there_is_a_project_with_content_items
    and_i_am_logged_in_as_a_gds_editor
    when_i_visit_the_project_page
    and_i_click_and_confirm_to_delete_the_project
    then_i_see_the_project_has_been_deleted
  end

  scenario "viewing a project with no bulk-tagging" do
    given_there_is_a_project_with_content_items_but_no_bulk_tagging
    when_i_visit_the_project_page
    then_there_is_no_bulk_tagging_interface
  end

  scenario "creating a new project with bulk-tagging" do
    given_there_is_a_remote_spreadsheet
    and_there_is_a_draft_taxonomy_branch
    when_i_create_a_new_project_with_bulk_tagging
    and_i_click_my_new_projects_name_in_the_project_list
    then_the_bulk_tagging_interface_is_present
  end

  scenario "filtering for to do content items" do
    given_there_is_a_project_with_content_items_in_all_different_states
    when_i_visit_the_project_page
    and_i_filter_by_to_do
    then_i_can_see_todo_content_items
  end

  scenario "filtering for flagged content items" do
    given_there_is_a_project_with_content_items_in_all_different_states
    when_i_visit_the_project_page
    and_i_filter_by_flagged
    then_i_only_see_flagged_content_items
  end

  scenario "filtering for done content items" do
    given_there_is_a_project_with_content_items_in_all_different_states
    when_i_visit_the_project_page
    and_i_filter_by_done
    then_i_only_see_done_content_items
  end

  scenario "filtering by searching" do
    given_there_is_a_project_with_content_items_in_all_different_states
    when_i_visit_the_project_page
    and_i_filter_by_text
    then_i_only_see_content_items_matching_the_text_search
  end

  scenario "reviewing previously assigned tags" do
    given_there_is_a_project_with_a_tagged_content_item
    when_i_visit_the_project_page
    then_i_see_the_content_item_and_its_tag_data
  end

  scenario "marking a content item as done" do
    given_there_is_a_project_with_a_content_item
    when_i_visit_the_project_page
    and_i_mark_the_content_item_as_done
    then_the_content_item_should_not_show_in_the_to_do_list
  end

  scenario "viewing tagging progress for organisations" do
    stub_organisation_tagging_progress

    when_i_visit_the_project_index_page
    and_i_fill_in_and_submit_the_organisation_progress_form
    then_the_tagging_progress_for_the_organisations_will_be_shown
  end

  def and_i_fill_in_and_submit_the_organisation_progress_form
    organisations = [
      "department-for-transport",
      "high-speed-two-limited",
      "home-office",
      "maritime-and-coastguard-agency",
    ]

    fill_in "Organisation slugs", with: organisations.join(", ")
    click_on "Display progress"
  end

  def then_the_tagging_progress_for_the_organisations_will_be_shown
    within "table:last-of-type" do
      expect(page).to have_content "department-for-transport 18.34%"
      expect(page).to have_content "high-speed-two-limited 98.80%"
      expect(page).to have_content "home-office 0.00%"
      expect(page).to have_content "maritime-and-coastguard-agency 57.27%"
    end
  end

  def given_there_is_a_project_with_content_items
    @project = create :project, :with_content_items
    stub_draft_taxonomy_branch
    stub_empty_bulk_taxons_lookup
  end

  def given_there_is_a_project_with_a_content_item
    @project = create :project, :with_a_content_item
    stub_draft_taxonomy_branch
    stub_empty_bulk_taxons_lookup
  end

  def given_there_is_a_project_with_content_items_but_no_bulk_tagging
    @project = create :project, :with_content_items, :with_bulk_tagging_disabled
    stub_draft_taxonomy_branch
    stub_empty_bulk_taxons_lookup
  end

  def given_there_is_a_project_with_content_items_in_all_different_states
    @project = create :project
    @incomplete_content_item = create(
      :project_content_item, title: "To do item", project_id: @project.id
    )
    @done_content_item = create(
      :project_content_item, title: "Done item", done: true, project_id: @project.id
    )
    @flagged_content_item = create(
      :project_content_item, :flagged_needs_help, title: "Flagged item", project_id: @project.id
    )
    create(
      :project_content_item, title: "Foo item", project_id: @project.id
    )
    stub_draft_taxonomy_branch
    stub_empty_bulk_taxons_lookup
  end

  def given_there_is_a_project_with_a_tagged_content_item
    @project = create :project
    @content_item = create(
      :project_content_item, title: "Foo", project_id: @project.id
    )
    @taxons = [SecureRandom.uuid]
    stub_bulk_taxons_lookup([@content_item.content_id], @taxons)
    stub_draft_taxonomy_branch
  end

  def and_i_am_logged_in_as_a_gds_editor
    login_as create(:user, :gds_editor)
  end

  def and_i_click_and_confirm_to_delete_the_project
    click_link "Delete"
    click_button "Confirm delete"
  end

  def then_i_see_the_content_item_and_its_tag_data
    within('.content-item:first') do
      expect(page).to have_content @content_item.title
      on_page_taxons = find('.select2')['data-taxons']
      expect(on_page_taxons).to eql @taxons.to_s
    end
  end

  def and_i_click_my_new_projects_name_in_the_project_list
    within 'table:first-of-type' do
      click_on @project_name
    end
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

  def when_i_create_a_new_project_with_bulk_tagging
    @project_name = 'my_project'
    visit projects_path
    click_link 'Add new project'
    fill_in 'new_project_form_name', with: @project_name
    select draft_taxon_title, from: 'Branch of GOV.UK taxonomy'
    fill_in 'new_project_form_remote_url', with: 'http://www.example.com/my_csv'
    check 'Bulk tagging'
    allow(LookupContentIdWorker).to receive(:perform_async)
    click_on 'New Project'

    content_item = create(
      :project_content_item, title: "Foo", project_id: Project.first.id
    )
    taxons = [SecureRandom.uuid]
    stub_bulk_taxons_lookup([content_item.content_id], taxons)
    stub_draft_taxonomy_branch
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

  def and_i_filter_by_done
    within '.filter-controls' do
      choose("Done")
      click_button("Apply")
    end
  end

  def and_i_filter_by_flagged
    within '.filter-controls' do
      choose("Flagged")
      click_button("Apply")
    end
  end

  def and_i_filter_by_to_do
    within '.filter-controls' do
      choose("To Do")
      click_button("Apply")
    end
  end

  def and_i_filter_by_text
    within '.filter-controls' do
      fill_in "title_search", with: "foo"
      click_button("Apply")
    end
  end

  def and_i_mark_the_content_item_as_done
    click_button "Done"
  end

  def then_i_can_see_my_new_project_in_the_list
    expect(page).to have_content 'my_project'
  end

  def then_i_see_the_project_has_been_deleted
    expect(page).to have_content 'You have sucessfully deleted the project'
    expect(page).not_to have_content 'project title'
  end

  def then_i_can_see_todo_content_items_for_that_project
    @project.content_items.each do |content_item|
      expect(page).to have_content content_item.title
    end
  end

  def then_i_only_see_done_content_items
    expect(page).to have_content @done_content_item.title
    expect(page).not_to have_content @flagged_content_item.title
    expect(page).not_to have_content @incomplete_content_item.title
  end

  def then_i_only_see_flagged_content_items
    expect(page).not_to have_content @done_content_item.title
    expect(page).to have_content @flagged_content_item.title
    expect(page).not_to have_content @incomplete_content_item.title
  end

  def then_i_can_see_todo_content_items
    expect(page).not_to have_content @done_content_item.title
    expect(page).not_to have_content @flagged_content_item.title
    expect(page).to have_content @incomplete_content_item.title
  end

  def then_i_only_see_content_items_matching_the_text_search
    expect(page).not_to have_content @done_content_item.title
    expect(page).not_to have_content @flagged_content_item.title
    expect(page).not_to have_content @incomplete_content_item.title
    expect(page).to have_content "Foo item"
  end

  def then_the_bulk_tagging_interface_is_present
    expect(page).to have_selector '.bulk-tagger'
  end

  def then_there_is_no_bulk_tagging_interface
    expect(page).not_to have_selector '.bulk-tagger'
  end

  def then_the_content_item_should_not_show_in_the_to_do_list
    expect(page).not_to have_content 'Foo'
  end
end
