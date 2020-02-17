require "rails_helper"

RSpec.feature "Navigation", type: :feature do
  include TaxonomyHelper
  include PublishingApiHelper

  scenario "User with no specific permissions" do
    given_i_am_logged_in_as_a_user_with_no_special_permissions
    when_i_visit_the_application
    then_i_dont_have_any_options_in_the_nav_bar
  end

  scenario "Tagathon participants can access Projects and Analytics only" do
    given_i_am_logged_in_as_a_tagathon_participant
    when_i_visit_the_application
    then_i_can_only_see_the_tagathon_options_in_the_nav_bar
  end

  scenario "Managing Editors can access Projects and Analytics only" do
    given_i_am_logged_in_as_a_managing_editor
    when_i_visit_the_application
    then_i_can_only_see_the_tagathon_options_in_the_nav_bar
  end

  scenario "GDS Editors can access all areas" do
    given_i_am_logged_in_as_a_gds_editor
    when_i_visit_the_application
    then_i_can_see_the_full_set_of_navigation_options
  end

  context "Clicking navigation option" do
    before do
      given_i_am_logged_in_as_a_gds_editor
      when_i_visit_the_application
    end

    navigation_options = ["Edit a page", "Bulk tag", "Edit taxonomy", "Tagging history", "Taxonomy Health", "Projects"].freeze
    navigation_paths = %w[/taggings/lookup /bulk_tag/new /taxons /tagging_history /taxonomy/health_warnings /projects].freeze

    navigation_options.zip(navigation_paths).each do |option, path|
      scenario "#{option} redirects to the correct page" do
        stub_get_request(option)
        and_when_i_click_navigation_option(option)
        then_i_am_redirected_to_the_page(path)
      end
    end
  end

  def given_i_am_logged_in_as_a_user_with_no_special_permissions
    login_as create(:user)
  end

  def given_i_am_logged_in_as_a_tagathon_participant
    login_as create(:user, :tagathon_participant)
  end

  def given_i_am_logged_in_as_a_managing_editor
    login_as create(:user, :managing_editor)
  end

  def given_i_am_logged_in_as_a_gds_editor
    login_as create(:user, :gds_editor)
  end

  def when_i_visit_the_application
    publishing_api_has_taxons([])
    visit root_path
  end

  def then_i_dont_have_any_options_in_the_nav_bar
    within "#navbar-header-menu-items" do
      expect(page).not_to have_text "Edit a page"
      expect(page).not_to have_text "Bulk tag"
      expect(page).not_to have_text "Edit taxonomy"
      expect(page).not_to have_text "Tagging history"
      expect(page).not_to have_text "Taxonomy Health"
      expect(page).not_to have_text "Projects"
    end
  end

  def then_i_can_only_see_the_tagathon_options_in_the_nav_bar
    within "nav .navbar-nav" do
      expect(page).not_to have_text "Edit a page"
      expect(page).not_to have_text "Bulk tag"
      expect(page).not_to have_text "Edit taxonomy"
      expect(page).not_to have_text "Tagging history"
      expect(page).not_to have_text "Taxonomy Health"
      expect(page).to have_text "Projects"
    end
  end

  def then_i_can_see_the_full_set_of_navigation_options
    within "nav .navbar-nav" do
      expect(page).to have_text "Edit a page"
      expect(page).to have_text "Bulk tag"
      expect(page).to have_text "Edit taxonomy"
      expect(page).to have_text "Tagging history"
      expect(page).to have_text "Taxonomy Health"
      expect(page).to have_text "Projects"
    end
  end

  def and_when_i_click_navigation_option(option)
    within "nav .navbar-nav" do
      click_link option
    end
  end

  def then_i_am_redirected_to_the_page(path)
    expect(page).to have_current_path(path)
  end

  def stub_get_request(option)
    stubbed_request_data = {
      "Tagging history" => {
        url: "https://publishing-api.test.gov.uk/v2/links/changes?link_types%5B%5D=taxons",
        body: { link_changes: [] },
      },
    }

    stub_request(:get, stubbed_request_data[option][:url]).to_return(status: 200, body: stubbed_request_data[option][:body].to_json) unless stubbed_request_data[option].nil?
  end
end
