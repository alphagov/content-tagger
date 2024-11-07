# require "gds_api/base"
# This work is necessary to meet the following WCAG guidelines:
# https://www.w3.org/WAI/WCAG22/Understanding/page-titled.html
# https://www.w3.org/WAI/WCAG22/Techniques/failures/F25
#
# For local testing with test data
LOCAL_ROOT_CONTENT_ID = "f186bbc9-09c8-4848-897d-f77dadb693fb"
PROD_ROOT_CONTENT_ID = "91b8ef20-74e7-4552-880c-50e6d73c2ff9"

namespace :worldwide do
  # For accessibility reasons, taxon titles need to be more unique. Having multiple versions of pages for different
  # countries all titled e.g. 'Trade and invest' goes against WCAG guidelines.
  desc "Update worldwide taxon titles (external name) to include the name of the country they relate to"

  # TODO: Add exception handling, especially when calling the API
  task add_country_name_to_title: :environment do
    # Build a taxonomy tree with the grandparent
    # (common ancestor e.g. /world/all - Help and services around the world) as the root
    taxonomy = Taxonomy::ExpandedTaxonomy.new(LOCAL_ROOT_CONTENT_ID).build.child_expansion

    taxonomy.tree.each do |linked_item|
      # This tree will include the root as well - need to skip that or if the taxon is a GENERIC (template) version
      next if linked_item.content_id == LOCAL_ROOT_CONTENT_ID || linked_item.internal_name.index("(GENERIC)") != nil

      # TODO: For each change. Write out to a CSV file the current title and what the title would be changed to.
      # This will need to be checked by the Content Designers but ensure that no changes are saved or published until
      # we can test fully.
      # TODO: Make sure the second task is able to revert and publish all changes.

      internal_name = linked_item.internal_name
      puts "Internal name = #{internal_name}"

      # As this is a tree, we reach all grandchildren without another loop (not a nested array)
      # example grandchild url /world/passports-and-emergency-travel-documents-cape-verde

      # If child - country pages (parent e.g. /world/argentina - UK help and services in Argentina) skip
      # Skip titles where the country name is already included at the end
      next if ((internal_name.start_with?("UK help and services in ") || internal_name.start_with?("Living in") || internal_name.start_with?("Travelling to")))

      # Adding the appropriate suffix:
      # -------------
      # Birth, death and marriage abroad in COUNTRY_NAME
      # British embassy or high commission in COUNTRY_NAME
      # Emergency help for British nationals in COUNTRY_NAME
      # News and events in COUNTRY_NAME
      # Passports and emergency travel documents in COUNTRY_NAME
      # Tax, benefits, pensions and working abroad in COUNTRY_NAME
      # --------------
      # Coming to the UK from COUNTRY_NAME
      # Trade and invest with COUNTRY_NAME
      case internal_name
      when "Coming to the UK", "Trade and invest"
        # Just these two titles need this 'from [COUNTRY_NAME]' suffix
        puts "adding - ...from COUNTRY_NAME"
        new_title = internal_name.gsub("(", "from ")
        new_title.gsub!(")", "")
      else
        # All other titles need this 'in [COUNTRY_NAME]' suffix
        puts "adding - ...in COUNTRY_NAME"
        new_title = internal_name.gsub("(", "in ")
        new_title.gsub!(")", "")
      end

      # Fetch the taxon and update accordingly
      if new_title
        puts "New title = #{new_title}"
        new_taxon = Taxonomy::BuildTaxon.call(content_id: linked_item.content_id)
        new_taxon.title = new_title
        # Save
        Taxonomy::UpdateTaxon.call(taxon: new_taxon)
      end
    end

    # Need to publish all drafts created by above, if latest edition is published
    # Draft editions are updated straight away.
    # TODO: Fix this (maybe it won't work locally? RedisClient::CannotConnectError)
    # Jon's advice - need to run the Publishing Api locally (-app flag) and maybe Content store
    Taxonomy::BulkPublishTaxon.call(LOCAL_ROOT_CONTENT_ID)
  end

  # Necessary for testing before release
  desc "Revert worldwide taxon titles (external name) to original text (remove the name of the country they relate to)"
  task remove_country_name_from_title: :environment do
    taxonomy = Taxonomy::ExpandedTaxonomy.new(LOCAL_ROOT_CONTENT_ID).build.child_expansion

    taxonomy.tree.each do |linked_item|
      # Skip root and GENERIC (template?) taxons
      next if linked_item.content_id == LOCAL_ROOT_CONTENT_ID || linked_item.internal_name.index("(GENERIC)") != nil

      title = linked_item.title
      puts "Internal name = #{title}"

      next if ((title.start_with?("UK help and services in ") || title.start_with?("Living in") || title.start_with?("Travelling to")))

      # Remove the added suffix:
      case title
      when "Coming to the UK", "Trade and invest"
        puts "removing - ...from COUNTRY_NAME from #{title}"
        suffix_index = title.index(" from ")
        new_title = title[0..(suffix_index - 1)]
      else
        # All other titles need this 'in [COUNTRY_NAME]' suffix
        puts "removing - ...in COUNTRY_NAME from #{title}"
        suffix_index = title.index(" in ")
        new_title = title[0..(suffix_index - 1)]
      end

      # Fetch the taxon and update accordingly
      if new_title
        puts "New title = #{new_title}"
        new_taxon = Taxonomy::BuildTaxon.call(content_id: linked_item.content_id)
        new_taxon.title = new_title
        # Save
        Taxonomy::UpdateTaxon.call(taxon: new_taxon)
      end
    end

  #   TODO: Publish all draft editions of taxons created by editing published editions
  end
end