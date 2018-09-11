require "rails_helper"

RSpec.feature "Tagging History", type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario "Show added link changes" do
    given_there_are_some_added_link_changes
    when_i_visit_the_tagging_history_index_page
    then_i_see_a_list_of_added_link_changes
  end

  scenario "Show removed link changes" do
    given_there_are_some_removed_link_changes
    when_i_visit_the_tagging_history_index_page
    then_i_see_a_list_of_removed_link_changes
  end

  scenario "Show user and organisation" do
    given_there_are_some_link_changes_with_user_data
    when_i_visit_the_tagging_history_index_page
    then_i_see_the_user_and_organisation
  end

  scenario "Show link changes with missing document information" do
    given_there_are_some_link_changes_with_missing_document_information
    when_i_visit_the_tagging_history_index_page
    then_i_see_a_list_of_link_changes_with_missing_document_information
  end

  scenario "Show changes for an individual taxon" do
    given_that_the_publishing_api_has_an_individual_taxon
    given_there_are_some_link_changes_for_an_individual_taxon
    when_i_visit_the_tagging_history_show_page
    then_i_see_the_link_changes_for_the_individual_taxon
  end

  scenario "Show changes for an individual taxon with missing source document information" do
    given_that_the_publishing_api_has_an_individual_taxon
    given_there_are_some_link_changes_for_an_individual_taxon_with_missing_source_document_information
    when_i_visit_the_tagging_history_show_page
    then_i_see_the_link_changes_for_the_individual_taxon_with_missing_source_document_information
  end

  private

  def given_there_are_some_added_link_changes
    stub_link_changes_request(added_link_changes)
  end

  def given_there_are_some_removed_link_changes
    stub_link_changes_request(removed_link_changes)
  end

  def given_there_are_some_link_changes_with_missing_document_information
    stub_link_changes_request(link_changes_with_missing_document_information)
  end

  def given_there_are_some_link_changes_with_user_data
    stub_link_changes_request(link_changes_with_user_data)
  end

  def given_that_the_publishing_api_has_an_individual_taxon
    publishing_api_has_item(individual_taxon)
  end

  def given_there_are_some_link_changes_for_an_individual_taxon
    stub_link_changes_request(
      link_changes_for_an_individual_taxon,
      link_types: %w[taxons],
      target_content_ids: [individual_taxon[:content_id]]
    )
  end

  def given_there_are_some_link_changes_for_an_individual_taxon_with_missing_source_document_information
    stub_link_changes_request(
      link_changes_for_an_individual_taxon_with_missing_source_document_information,
      link_types: %w[taxons],
      target_content_ids: [individual_taxon[:content_id]]
    )
  end

  def when_i_visit_the_tagging_history_index_page
    visit tagging_history_index_path
  end

  def when_i_visit_the_tagging_history_show_page
    visit tagging_history_path(individual_taxon[:content_id])
  end

  def then_i_see_a_list_of_added_link_changes
    check_index_page_link_changes_table(added_link_changes)
  end

  def then_i_see_a_list_of_removed_link_changes
    check_index_page_link_changes_table(removed_link_changes)
  end

  def then_i_see_a_list_of_link_changes_with_missing_document_information
    check_index_page_link_changes_table(link_changes_with_missing_document_information)
  end

  def check_index_page_link_changes_table(link_changes)
    page.all('tbody tr').zip(link_changes).each do |tr, link_change|
      if link_change['source']
        expect(tr).to have_link(
          link_change['source']['title'],
          href: website_url(link_change['source']['base_path'])
        )
      else
        expect(tr).to have_text 'unknown document'
      end

      if link_change['target']
        expect(tr).to have_link(
          link_change['target']['title'],
          href: tagging_history_path(link_change['target']['content_id'])
        )
      else
        expect(tr).to have_text 'unknown taxon'
      end

      expect(tr).to have_text(link_change['change'] == 'add' ? 'tagged' : 'removed')
      expect(tr).to have_text('Unknown user')
    end
  end

  def then_i_see_the_user_and_organisation
    page.all('tbody tr').each do |tr|
      expect(tr).to have_text('Foo')
      expect(tr).to have_text('Bar baz')
    end
  end

  def then_i_see_the_link_changes_for_the_individual_taxon
    page.all('tbody tr').zip(link_changes_for_an_individual_taxon).each do |tr, link_change|
      expect(tr).to have_link(
        link_change['source']['title'],
        href: website_url(link_change['source']['base_path'])
      )
    end
  end

  def then_i_see_the_link_changes_for_the_individual_taxon_with_missing_source_document_information
    page.all('tbody tr').zip(link_changes_for_an_individual_taxon_with_missing_source_document_information).each do |tr, link_change|
      if link_change['source']
        expect(tr).to have_link(
          link_change['source']['title'],
          href: website_url(link_change['source']['base_path'])
        )
      else
        expect(tr).to have_text('unknown document')
      end
    end
  end

  def stub_link_changes_request(link_changes, params = { link_types: %w[taxons] })
    stub_request(:get, "#{PUBLISHING_API}/v2/links/changes?#{params.to_query}")
      .to_return(body: { link_changes: link_changes }.to_json)
  end

  def link_changes_with_user_data
    user = FactoryBot.create(:user, name: 'Foo', organisation_slug: 'bar-baz')
    @_link_changes_with_user_data ||= FactoryBot.build_list(:link_change, 3, change: 'add', user_uid: user.uid)
  end

  def added_link_changes
    @_added_link_changes ||= FactoryBot.build_list(:link_change, 3, change: 'add')
  end

  def removed_link_changes
    @_removed_link_changes ||= FactoryBot.build_list(:link_change, 3, change: 'remove')
  end

  def link_changes_with_missing_document_information
    @_link_changes_with_missing_document_information ||= begin
      link_changes = FactoryBot.build_list(:link_change, 3)
      link_changes[0]['source'] = nil
      link_changes[1]['target'] = nil
      link_changes[2]['source'] = nil
      link_changes[2]['target'] = nil
      link_changes
    end
  end

  def link_changes_for_an_individual_taxon_with_missing_source_document_information
    @_link_changes_with_missing_document_information ||= begin
      link_changes = FactoryBot.build_list(
        :link_change,
        2,
        target: { content_id: individual_taxon[:content_id] }
      )
      link_changes[1]['source'] = nil
      link_changes
    end
  end

  def individual_taxon
    basic_content_item("Taxon 1")
  end

  def link_changes_for_an_individual_taxon
    @_link_changes_for_an_individual_taxon ||= FactoryBot.build_list(
      :link_change,
      3,
      target: { content_id: individual_taxon[:content_id] }
    )
  end

  def website_url(base_path)
    Plek.new.website_root + base_path
  end
end
