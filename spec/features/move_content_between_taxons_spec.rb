require "rails_helper"

RSpec.feature "Move content between Taxons", type: :feature do
  include ContentItemHelper
  include PublishingApiHelper

  scenario "Successfully move content between existing taxons" do
    given_there_are_taxons
    when_i_visit_the_taxonomy_page
    and_view_the_first_taxon
    and_click_to_move_content_to_another_taxon
    and_select_a_taxon_to_move_content_to
    and_select_all_content
    and_preview_my_changes
    then_i_can_see_that_the_old_taxon_link_will_be_removed
    and_all_content_has_been_moved_when_i_start_the_content_move
  end

  def given_there_are_taxons
    @source_taxon = content_item_with_details(
      "Source taxon",
      other_fields: {
        document_type: 'taxon'
      }
    )
    @source_taxon_for_select = {
      'internal_name' => @source_taxon['details']['internal_name'],
      'content_id' => @source_taxon['content_id'],
      'publication_state' => 'live'
    }
    @dest_taxon = content_item_with_details(
      "Destination taxon",
      other_fields: {
        document_type: 'taxon'
      }
    )
    @dest_taxon_for_select = {
      'internal_name' => @dest_taxon['details']['internal_name'],
      'content_id' => @dest_taxon['content_id'],
      'publication_state' => 'live'
    }

    @document_1 = basic_content_item("Tagged content 1")
    @document_2 = basic_content_item("Tagged content 2")

    publishing_api_has_links(
      content_id: @source_taxon[:content_id],
      links: {},
      version: 1
    )
    publishing_api_has_expanded_links(
      content_id: @source_taxon[:content_id],
      expanded_links: {},
    )

    stub_request(
      :get,
      %r{publishing-api.test.gov.uk/v2/linked/#{@source_taxon[:content_id]}}
    ).to_return(
      body: [@document_1, @document_2].to_json
    )

    publishing_api_has_taxons([@source_taxon, @dest_taxon])
    publishing_api_has_item(@source_taxon)
    publishing_api_has_item(@dest_taxon)

    publishing_api_has_linkables(
      [@source_taxon_for_select, @dest_taxon_for_select],
      document_type: 'taxon'
    )
  end

  def when_i_visit_the_taxonomy_page
    visit taxons_path
  end

  def and_view_the_first_taxon
    first_row = first('table tbody tr')
    view_taxon_link = first_row.find('a', text: 'View taxon')

    view_taxon_link.click
  end

  def and_click_to_move_content_to_another_taxon
    find_link(I18n.t('views.taxons.move_content')).click
  end

  def and_select_a_taxon_to_move_content_to
    select @dest_taxon_for_select['internal_name']
  end

  def and_select_all_content
    all('table tbody input[type=checkbox]').each do |checkbox|
      checkbox.set(true)
    end
  end

  def and_preview_my_changes
    click_button I18n.t("bulk_tagging.preview")
  end

  def then_i_can_see_that_the_old_taxon_link_will_be_removed
    tag_migration = TagMigration.last

    expect(page).to have_text(
      I18n.t(
        'views.tag_migrations.move_message',
        taxon_name: tag_migration.source_title
      )
    )
  end

  def and_all_content_has_been_moved_when_i_start_the_content_move
    # Lookups to fetch the content ID based on existing base paths
    publishing_api_has_lookups(
      @document_1[:base_path] => @document_1[:content_id],
      @document_2[:base_path] => @document_2[:content_id]
    )

    # Make sure we assert the correct API calls are made
    assert_content_items_have_been_moved_for_document(
      @document_1,
      @source_taxon,
      @dest_taxon
    )
    assert_content_items_have_been_moved_for_document(
      @document_2,
      @source_taxon,
      @dest_taxon
    )

    Sidekiq::Testing.inline!
    click_link I18n.t('bulk_tagging.start_tagging')
  end

private

  def assert_content_items_have_been_moved_for_document(document, source, dest)
    # First we fetch existing links
    publishing_api_has_links(
      content_id: document[:content_id],
      links: { taxons: [source[:content_id]] },
      version: 1
    )
    # Then we patch them with the new link minus the old link
    # Note that 'source[:content_id]' dissapeared
    stub_publishing_api_patch_links(
      document[:content_id],
      links: { taxons: [dest[:content_id]] },
      previous_version: 1
    )
  end
end
