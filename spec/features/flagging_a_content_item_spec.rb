RSpec.describe "flagging a content item" do
  include TaxonomyHelper
  include PublishingApiHelper

  scenario "flagging a content_item as 'I need help'", :js do
    given_there_is_a_project_with_a_content_item
    when_i_visit_the_project_page
    and_i_flag_the_first_content_item_as_i_need_help
    and_i_enter_a_comment_to_explain_why_i_need_help
    and_i_submit_my_flag_for_review_choice
    and_i_apply_the_flagged_filter
    then_the_content_item_should_be_flagged_as_needs_help
    and_the_need_help_comment_should_be_displayed
  end

  scenario "flagging a content item and suggesting a new term", :js do
    given_there_is_a_project_with_a_content_item
    when_i_visit_the_project_page
    and_i_flag_the_first_content_item_as_missing_a_relevant_topic
    and_i_suggest_a_new_topic
    and_i_submit_my_flag_for_review_choice
    and_i_apply_the_flagged_filter
    then_the_content_item_should_be_flagged_as_missing_topic
    and_the_suggested_topic_should_be_displayed
  end

  scenario "flagged content is labelled in table view" do
    given_there_is_a_project_with_flagged_content_items
    when_i_visit_the_project_page
    and_i_apply_the_flagged_filter
    then_the_flagged_content_items_should_be_labelled_correctly
  end

  scenario "removing a flag" do
    given_there_is_a_project_with_a_flagged_content_item
    when_i_visit_the_project_page
    and_i_apply_the_flagged_filter
    and_i_mark_the_content_item_as_done
    then_the_content_item_should_no_longer_be_flagged
  end

  def given_there_is_a_project_with_a_content_item
    create(:project, :with_content_item)
    stub_empty_bulk_taxons_lookup
    stub_draft_taxonomy_branch
  end

  def given_there_is_a_project_with_flagged_content_items
    project = create(:project)
    create(:project_content_item, :flagged_needs_help, project:)
    create(:project_content_item, :flagged_missing_topic, project:)
    stub_empty_bulk_taxons_lookup
    stub_draft_taxonomy_branch
  end

  def given_there_is_a_project_with_a_flagged_content_item
    project = create(:project)
    create(:project_content_item, :flagged_needs_help, project:)
    stub_empty_bulk_taxons_lookup
    stub_draft_taxonomy_branch
  end

  def when_i_visit_the_project_page
    visit project_path(Project.first)
  end

  def and_i_flag_the_first_content_item_as_i_need_help
    click_link "Flag for review"
    choose "I need help tagging this"
  end

  def and_i_enter_a_comment_to_explain_why_i_need_help
    fill_in "Comment (optional)", with: "I don't know what I'm doing"
  end

  def and_i_submit_my_flag_for_review_choice
    click_button "Continue"
    wait_for_ajax
  end

  def and_i_apply_the_flagged_filter
    choose "Flagged"
    click_button "Apply filter"
  end

  def then_the_content_item_should_be_flagged_as_needs_help
    expect(page).to have_content "Flagged: needs publisher review"
  end

  def and_i_flag_the_first_content_item_as_missing_a_relevant_topic
    click_link "Flag for review"
    choose "There's no relevant topic for this"
  end

  def and_i_suggest_a_new_topic
    fill_in "Suggest a new topic", with: "cool new topic"
  end

  def and_i_mark_the_content_item_as_done
    click_button "Done"
  end

  def then_the_content_item_should_be_flagged_as_missing_topic
    expect(page).to have_content "Flagged: needs IA review"
  end

  def and_the_suggested_topic_should_be_displayed
    expect(page).to have_content "Suggested topic: cool new topic"
  end

  def then_the_flagged_content_items_should_be_labelled_correctly
    expect(page).to have_content "Flagged: needs publisher review"
    expect(page).to have_content "Flagged: needs IA review"
  end

  def then_the_content_item_should_no_longer_be_flagged
    expect(page).not_to have_content "Flagged: needs publisher review"
  end

  def and_the_need_help_comment_should_be_displayed
    expect(page).to have_content "Comment: I don't know what I'm doing"
  end
end
