require "rails_helper"

RSpec.feature "Analytics", type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario "Show added link changes" do
    given_there_are_some_added_link_changes
    when_i_visit_the_analytics_page
    then_i_see_a_list_of_added_link_changes
  end

  scenario "Show removed link changes" do
    given_there_are_some_removed_link_changes
    when_i_visit_the_analytics_page
    then_i_see_a_list_of_removed_link_changes
  end

private

  def given_there_are_some_added_link_changes
    stub_link_changes_request(added_link_changes)
  end

  def given_there_are_some_removed_link_changes
    stub_link_changes_request(removed_link_changes)
  end

  def when_i_visit_the_analytics_page
    visit analytics_path
  end

  def then_i_see_a_list_of_added_link_changes
    page.all('tbody tr').zip(added_link_changes).each do |tr, link_change|
      expect(tr).to have_link(link_change['source']['title'], href: link_change['source']['base_path'])
      expect(tr).to have_link(link_change['target']['title'], href: link_change['target']['base_path'])
      expect(tr).to have_text('tagged to')
    end
  end


  def then_i_see_a_list_of_removed_link_changes
    page.all('tbody tr').zip(removed_link_changes).each do |tr, link_change|
      expect(tr).to have_link(link_change['source']['title'], href: link_change['source']['base_path'])
      expect(tr).to have_link(link_change['target']['title'], href: link_change['target']['base_path'])
      expect(tr).to have_text('removed')
    end
  end

  def stub_link_changes_request(link_changes)
    stub_request(:get, "#{PUBLISHING_API}/v2/links/changes?link_types%5B%5D=taxons")
      .to_return(body: { link_changes: link_changes}.to_json)
  end

  def added_link_changes
    @_added_link_changes ||= FactoryGirl.build_list(:link_change, 3, change: 'add')
  end

  def removed_link_changes
    @_removed_link_changes ||= FactoryGirl.build_list(:link_change, 3, change: 'remove')
  end
end