require "rails_helper"

RSpec.feature "Manage Root Taxons" do
  include PublishingApiHelper
  include ContentItemHelper

  scenario "Update the list of root taxons" do
    given_that_there_are_two_taxons
    given_that_one_taxon_is_a_root_taxon
    given_that_one_link_is_a_root_taxon
    when_i_visit_the_edit_taxonomy_page
    and_i_click_the_manage_root_taxons_button
    and_i_click_the_edit_root_taxons_button
    and_i_add_a_new_taxon
    when_i_click_save
    then_the_set_of_root_taxons_is_updated
  end

  def given_that_there_are_two_taxons
    @linkable_taxon_hash = FactoryGirl.build_list(:linkable_taxon_hash, 2)
    publishing_api_has_taxons(
      [],
      page: 1,
      states: ["published"]
    )
    publishing_api_has_linkables(
      @linkable_taxon_hash,
      document_type: 'taxon'
    )
  end

  def given_that_one_taxon_is_a_root_taxon
    publishing_api_has_expanded_links(
      content_id: GovukTaxonomy::ROOT_CONTENT_ID,
      expanded_links: {
        root_taxons: [
          {
            content_id: @linkable_taxon_hash.first[:content_id]
          }
        ],
      }
    )
    publishing_api_has_expanded_links(
      {
        content_id: GovukTaxonomy::ROOT_CONTENT_ID,
        expanded_links: {
          root_taxons: [],
        }
      },
      with_drafts: false
    )
  end

  def given_that_one_link_is_a_root_taxon
    publishing_api_has_links(
      "content_id" => GovukTaxonomy::ROOT_CONTENT_ID,
      "links" => {
        "root_taxons" => @linkable_taxon_hash.first[:content_id]
      }
    )
  end

  def when_i_visit_the_edit_taxonomy_page
    visit taxons_path
  end

  def and_i_click_the_manage_root_taxons_button
    click_link "Manage root taxons"
  end

  def and_i_click_the_edit_root_taxons_button
    click_link "Edit root taxons"
  end

  def then_i_see_the_current_root_taxons
    expect(page).to have_text(@linkable_taxon_hash.first[:internal_name])
  end

  def and_i_add_a_new_taxon
    select @linkable_taxon_hash[1][:internal_name], from: "root_taxons_form_root_taxons"
  end

  def when_i_click_save
    stub_any_publishing_api_patch_links
    click_on "Save & publish"
  end

  def then_the_set_of_root_taxons_is_updated
    assert_publishing_api_patch_links(
      GovukTaxonomy::ROOT_CONTENT_ID,
      "links" => {
        "root_taxons" => @linkable_taxon_hash.map { |t| t[:content_id] }
      }
    )
  end
end
