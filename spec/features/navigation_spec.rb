require "rails_helper"

RSpec.feature "Navigation", type: :feature do
  include TaxonomyHelper

  before do
    stub_tagging_progress
  end

  scenario "User with no specific permissions" do
    given_i_am_logged_in_as_a_user_with_no_special_permissions
    when_i_visit_the_application
    then_i_will_see_the_permission_denied_page
  end

  scenario "Tagathon participants can access Projects and Analytics only" do
    given_i_am_logged_in_as_a_tagathon_participant
    when_i_visit_the_application
    then_i_can_only_see_the_tagathon_options_in_the_nav_bar
  end

  scenario "GDS Editors can access all areas" do
    given_i_am_logged_in_as_a_gds_editor
    when_i_visit_the_application
    then_i_can_see_the_full_set_of_navigation_options
  end

  def given_i_am_logged_in_as_a_user_with_no_special_permissions
    login_as create(:user)
  end

  def given_i_am_logged_in_as_a_tagathon_participant
    login_as create(:user, :tagathon_participant)
  end

  def given_i_am_logged_in_as_a_gds_editor
    login_as create(:user, :gds_editor)
  end

  def when_i_visit_the_application
    visit root_path
  end

  def then_i_will_see_the_permission_denied_page
    expect(page).to have_text "Sorry, you are not authorised to access this application."
  end

  def then_i_can_only_see_the_tagathon_options_in_the_nav_bar
    within "nav .navbar-nav" do
      expect(page).not_to have_text "Edit a page"
      expect(page).not_to have_text "Bulk tag"
      expect(page).not_to have_text "Edit taxonomy"
      expect(page).to have_text "Projects"
    end
  end

  def then_i_can_see_the_full_set_of_navigation_options
    within "nav .navbar-nav" do
      expect(page).to have_text "Edit a page"
      expect(page).to have_text "Bulk tag"
      expect(page).to have_text "Edit taxonomy"
      expect(page).to have_text "Projects"
    end
  end
end
