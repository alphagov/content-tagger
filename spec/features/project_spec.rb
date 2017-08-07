require 'rails_helper'

RSpec.feature "Projects", type: :feature do
  include RemoteCsvHelper

  scenario "viewing a project" do
    given_there_is_a_project_with_content_items
    when_i_visit_the_project_page
    then_i_can_see_all_the_content_items_for_that_project
  end

  scenario "creating a new project" do
    given_there_is_a_remote_spreadsheet
    when_i_visit_the_project_index_page
    and_i_click_the_new_project_link
    and_i_fill_in_a_name_and_url
    and_i_click_new_project
    then_i_can_see_my_new_project_in_the_list
  end

  def given_there_is_a_project_with_content_items
    @project = create :project, :with_content_items
  end

  def given_there_is_a_remote_spreadsheet
    stub_remote_csv
  end

  def when_i_visit_the_project_page
    visit root_path
    within 'header nav .nav' do
      click_link 'Projects'
    end
    click_link @project.name
  end

  def when_i_visit_the_project_index_page
    visit projects_path
  end

  def and_i_click_the_new_project_link
    click_link 'Add new project'
    expect(page).to have_content 'New Project'
  end

  def and_i_fill_in_a_name_and_url
    fill_in 'new_project_form_name', with: 'my_project'
    fill_in 'new_project_form_remote_url', with: 'http://www.example.com/my_csv'
  end

  def and_i_click_new_project
    click_on 'New Project'
  end

  def then_i_can_see_my_new_project_in_the_list
    expect(page).to have_content 'my_project'
  end

  def then_i_can_see_all_the_content_items_for_that_project
    @project.content_items.each do |content_item|
      expect(page).to have_content content_item.title
    end
  end
end
