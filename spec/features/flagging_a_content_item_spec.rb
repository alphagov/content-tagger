require 'rails_helper'

RSpec.describe "flagging a content item" do
  include TaxonomyHelper
  include PublishingApiHelper

  scenario "flagging a content_item as 'I need help'" do
    given_there_is_a_project_with_a_content_item
    when_i_visit_the_project_page
    and_i_flag_the_first_content_item_as_i_need_help
    then_the_content_item_should_be_flagged_as_needs_help
  end

  scenario "flagging a content item and suggesting a new term" do
    given_there_is_a_project_with_a_content_item
    when_i_visit_the_project_page
    and_i_flag_the_first_content_item_as_missing_a_relevant_topic_and_i_suggest_a_new_term
    then_them_content_item_should_be_flagged_as_missing_topic
    and_there_should_be_an_associated_suggestion
  end

  def given_there_is_a_project_with_a_content_item
    create(:project, :with_content_item)
    stub_empty_bulk_taxons_lookup
    stub_draft_taxonomy_branch
  end

  def when_i_visit_the_project_page
    visit project_path(Project.first)
  end

  def and_i_flag_the_first_content_item_as_i_need_help
    click_link 'Flag for review'
    choose "I need help tagging this"
    click_button "Continue"
  end

  def then_the_content_item_should_be_flagged_as_needs_help
    expect(Project.first.content_items.first.needs_help?).to be true
  end

  def and_i_flag_the_first_content_item_as_missing_a_relevant_topic_and_i_suggest_a_new_term
    click_link 'Flag for review'
    choose "There's no relevant topic for this"
    fill_in "Suggest a new topic", with: "cool new topic"
    click_button "Continue"
  end

  def then_them_content_item_should_be_flagged_as_missing_topic
    expect(Project.first.content_items.first.missing_topic?).to be true
  end

  def and_there_should_be_an_associated_suggestion
    expect(Project.first.content_items.first.suggested_tags).to eql "cool new topic"
  end
end
