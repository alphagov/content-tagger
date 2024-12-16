# This task is to update the titles of worldwide taxons to include the country name they relate to.
# This work is necessary to meet the following WCAG guidelines:
# https://www.w3.org/WAI/WCAG22/Understanding/page-titled.html
# https://www.w3.org/WAI/WCAG22/Techniques/failures/F25

# For local testing with test data
LOCAL_ROOT_CONTENT_ID = "f186bbc9-09c8-4848-897d-f77dadb693fb".freeze
INTEGRATION_ROOT_CONTENT_ID = "369729ba-7776-4123-96be-2e3e98e153e1".freeze
# PROD_ROOT_CONTENT_ID = "91b8ef20-74e7-4552-880c-50e6d73c2ff9".freeze - need to check this is correct!

ROOT_CONTENT_ID = INTEGRATION_ROOT_CONTENT_ID

namespace :worldwide do
  # For accessibility reasons, taxon titles need to be more unique. Having multiple versions of pages for different
  # countries all titled e.g. 'Trade and invest' goes against WCAG guidelines.
  desc "Update worldwide taxon titles (external name) to include the name of the country they relate to"

  task :add_country_name_to_title, %i[log_file_path] => :environment do |_, args|
    log_file = nil
    if args[:log_file_path]
      log_file = File.open(args[:log_file_path], "w")
      # log_file.puts("Updating worldwide taxons to include country name in their title")
      puts("Updating worldwide taxons to include country name in their title")
    end
    # TODO: Remove this testing code
    count = 0

    puts("Running taxonomy expansion")
    # Build a taxonomy tree with the grandparent
    # (common ancestor e.g. /world/all - Help and services around the world) as the root
    taxonomy = Taxonomy::ExpandedTaxonomy.new(ROOT_CONTENT_ID).build.child_expansion
    puts("Taxonomy has size #{taxonomy.tree.size}")

    taxonomy.tree.each do |linked_item|
      # TODO: Remove this testing code
      if count == 5
        break
      end

      puts(count)
      # This tree will include the root as well - need to skip that or if the taxon is a GENERIC (template) version
      next if linked_item.content_id == ROOT_CONTENT_ID || !linked_item.internal_name.index("(GENERIC)").nil?

      # TODO: For each change. Write out to a CSV file the current title and what the title would be changed to.
      # This will need to be checked by the Content Designers but ensure that no changes are saved or published until
      # we can test fully.
      # TODO: Make sure the second task is able to revert and publish all changes.

      internal_name = linked_item.internal_name
      message = "Internal name = #{internal_name}"
      puts(message)

      # As this is a tree, we reach all grandchildren without another loop (not a nested array)
      # example grandchild url /world/passports-and-emergency-travel-documents-cape-verde

      # Skip titles where the country name is already included at the end
      # e.g. If child - country pages (parent e.g. /world/argentina - UK help and services in Argentina)
      if internal_name.start_with?("UK help and services in ") || internal_name.start_with?("Living in") || internal_name.start_with?("Travelling to")
        message = "Skipping #{internal_name} as it already includes the country name"
        # log_file ? log_file.puts(message) : puts(message)
        puts(message)
        next
      end
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
      when "Coming to the UK"
        puts "adding - ...from COUNTRY_NAME"
        new_title = internal_name.gsub("(", "from ")
      when "Trade and invest"
        puts "adding - ...with COUNTRY_NAME"
        new_title = internal_name.gsub("(", "with ")
      else
        # All other titles need this 'in [COUNTRY_NAME]' suffix
        puts "adding - ...in COUNTRY_NAME"
        new_title = internal_name.gsub("(", "in ")
      end
      new_title.gsub!(")", "")

      # Fetch the taxon and update accordingly
      if new_title
        puts "New title = #{new_title}"
        new_taxon = Taxonomy::BuildTaxon.call(content_id: linked_item.content_id)
        new_taxon.title = new_title
        # Save
        Taxonomy::UpdateTaxon.call(taxon: new_taxon)
        message = "Updated taxon #{linked_item.title} to #{new_title}"
      end
      # log_file ? log_file.puts(message) : puts(mess
      puts(message)

      # TODO: Remove this testing code
      count += 1
    rescue InvalidTaxonError => e
      error_message = "An error occurred while processing taxon #{internal_name}: #{e.message}"
      # log_file ? log_file.puts(error_message) : puts(error_message)
      puts(error_message)
    end

    # Need to publish all drafts created by above, if latest edition is published
    # Draft editions are updated straight away.
    # TODO: Fix this (maybe it won't work locally? RedisClient::CannotConnectError)
    # Jon's advice - need to run the Publishing Api locally (-app flag) and maybe Content store
    Taxonomy::BulkPublishTaxon.call(ROOT_CONTENT_ID)
  rescue GdsApi::HTTPConflict, GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException => e
    error_message = "An error occurred while publishing taxons: #{e.message}"
    # log_file ? log_file.puts(error_message) : puts(error_message)
    puts(error_message)
  rescue StandardError => e
    error_message = "An error occurred while publishing taxons: #{e.message}"
    # log_file ? log_file.puts(error_message) : puts(error_message)
    puts(error_message)
  end

  # Necessary for testing before release
  desc "Revert worldwide taxon titles (external name) to original text (remove the name of the country they relate to)"
  task remove_country_name_from_title: :environment do
    taxonomy = Taxonomy::ExpandedTaxonomy.new(ROOT_CONTENT_ID).build.child_expansion

    taxonomy.tree.each do |linked_item|
      # Skip root and GENERIC (template?) taxons
      next if linked_item.content_id == ROOT_CONTENT_ID || !linked_item.internal_name.index("(GENERIC)").nil?

      title = linked_item.title
      puts "Internal name = #{title}"

      next if title.start_with?("UK help and services in ") || title.start_with?("Living in") || title.start_with?("Travelling to")

      # Remove the added suffix:
      case title
      when "Coming to the UK"
        puts "removing - ...from COUNTRY_NAME from #{title}"
        suffix_index = title.index(" from ")
      when "Trade and invest"
        puts "removing - ...with COUNTRY_NAME from #{title}"
        suffix_index = title.index(" with ")
      else
        # All other titles need this 'in [COUNTRY_NAME]' suffix
        puts "removing - ...in COUNTRY_NAME from #{title}"
        suffix_index = title.index(" in ")
      end
      new_title = title[0..(suffix_index - 1)]

      # Fetch the taxon and update accordingly
      next unless new_title

      puts "New title = #{new_title}"
      new_taxon = Taxonomy::BuildTaxon.call(content_id: linked_item.content_id)
      new_taxon.title = new_title
      # Save
      Taxonomy::UpdateTaxon.call(taxon: new_taxon)
    end

    #   TODO: Publish all draft editions of taxons created by editing published editions
  end
end
