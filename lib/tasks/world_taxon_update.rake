# This task is to update the titles of each worldwide taxon to include the country name they relate to.
# This work is necessary to meet the following WCAG guidelines:
# https://www.w3.org/WAI/WCAG22/Understanding/page-titled.html
# https://www.w3.org/WAI/WCAG22/Techniques/failures/F25
# For accessibility reasons, taxon titles need to be more unique. Having multiple versions of pages for different
# countries all titled e.g. 'Trade and invest' goes against WCAG guidelines.

ROOT_CONTENT_ID = "91b8ef20-74e7-4552-880c-50e6d73c2ff9".freeze

namespace :worldwide do
  desc "Update worldwide taxon titles (external name) to include the name of the country they relate to"

  task :add_country_name_to_title, %i[log_file_path] => :environment do |_, args|
    log_file = nil
    if args[:log_file_path]
      log_file = File.open(args[:log_file_path], "w")
      log_file.puts("Updating each worldwide taxon to include country name in their title")
    end
    puts("Updating each worldwide taxon to include country name in their title")

    total_taxon_updates = 0

    # Build a taxonomy tree with the grandparent
    # (common ancestor e.g. /world/all - Help and services around the world) as the root
    taxonomy = Taxonomy::ExpandedTaxonomy.new(ROOT_CONTENT_ID).build.child_expansion
    log_file&.puts("Taxonomy has size #{taxonomy.tree.size}")
    puts("Taxonomy has size #{taxonomy.tree.size}")

    taxonomy.tree.each do |linked_item|
      # Tree includes root (world/all) - skip that or if the taxon is a GENERIC (template) version
      next if linked_item.content_id == ROOT_CONTENT_ID || linked_item.internal_name.include?("(GENERIC)")

      internal_name = linked_item.internal_name
      message = "Internal name = #{internal_name}"
      log_file ? log_file.puts(message) : puts(message)

      # As this is a tree, we reach all grandchildren without another loop (not a nested array)
      # example grandchild url /world/passports-and-emergency-travel-documents-cape-verde

      # Skip titles where the country name is already included at the end
      # e.g. If child - country pages (parent e.g. /world/argentina - UK help and services in Argentina)
      if internal_name.start_with?("UK help and services in ") || internal_name.start_with?("Living in") || internal_name.start_with?("Travelling to")
        message = "Skipping #{internal_name} as it already includes the country name"
        log_file ? log_file.puts(message) : puts(message)
        next
      end
      # Adding the appropriate suffix as follows:
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

      new_title = ""
      if internal_name.start_with?("Coming to the UK")
        message = "adding - ...from COUNTRY_NAME"
        new_title = internal_name.gsub("(", "from ")
      elsif internal_name.start_with?("Trade and invest")
        message = "adding - ...with COUNTRY_NAME"
        new_title = internal_name.gsub("(", "with ")
      else
        message = "adding - ...in COUNTRY_NAME"
        new_title = internal_name.gsub("(", "in ")
      end
      new_title.gsub!(")", "")
      log_file ? log_file.puts(message) : puts(message)

      # Fetch the taxon and update accordingly
      if new_title
        new_taxon = Taxonomy::BuildTaxon.call(content_id: linked_item.content_id)
        new_taxon.title = new_title
        # Save the taxon with the new title
        Taxonomy::UpdateTaxon.call(taxon: new_taxon)
        message = "Updated taxon #{linked_item.title} to #{new_title}"
      end
      log_file ? log_file.puts(message) : puts(message)
      total_taxon_updates += 1
    rescue InvalidTaxonError => e
      error_message = "An error occurred while processing taxon #{internal_name}: #{e.message}"
      log_file&.puts(error_message)
      puts(error_message)
    end

    # Need to publish all the drafts we have created above (if latest edition is published)
    # - Draft editions are updated straight away.
    puts("Publishing all updated taxons")
    Taxonomy::BulkPublishTaxon.call(ROOT_CONTENT_ID)
    message = "Total number of taxons updated - #{total_taxon_updates}"
    log_file&.puts(message)
    puts(message)
  rescue GdsApi::HTTPConflict, GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException => e
    error_message = "An error occurred while publishing taxons: #{e.full_message}"
    log_file&.puts(error_message)
    puts(error_message)
  rescue StandardError => e
    error_message = "A standard error occurred while publishing taxons: #{e.full_message}"
    log_file&.puts(error_message)
    puts(error_message)
  ensure
    log_file&.close
  end

  # Necessary for testing before release to revert all changed titles back to their original state
  desc "Revert worldwide taxon titles (external name) to original text (remove the name of the country they relate to)"
  task remove_country_name_from_title: :environment do
    puts("Reverting worldwide taxon titles to remove country name")
    taxonomy = Taxonomy::ExpandedTaxonomy.new(ROOT_CONTENT_ID).build.child_expansion

    taxonomy.tree.each do |linked_item|
      next if linked_item.content_id == ROOT_CONTENT_ID || linked_item.internal_name.include?("(GENERIC)")

      title = linked_item.title
      puts "Internal name = #{title}"

      next if title.start_with?("UK help and services in ") || title.start_with?("Living in") || title.start_with?("Travelling to")

      suffix_index = nil
      if title.start_with?("Coming to the UK from")
        puts "removing - ...from COUNTRY_NAME from #{title}"
        suffix_index = title.index(" from ")
      elsif title.start_with?("Trade and invest with")
        puts "removing - ...with COUNTRY_NAME from #{title}"
        suffix_index = title.index(" with ")
      elsif title.include?(" in ")
        puts "removing - ...in COUNTRY_NAME from #{title}"
        suffix_index = title.index(" in ")
      end

      next unless suffix_index

      new_title = title[0..(suffix_index - 1)]
      puts "New title = #{new_title}"

      new_taxon = Taxonomy::BuildTaxon.call(content_id: linked_item.content_id)
      new_taxon.title = new_title

      Taxonomy::UpdateTaxon.call(taxon: new_taxon)
    rescue InvalidTaxonError => e
      error_message = "An error occurred while processing taxon #{internal_name}: #{e.message}"
      puts(error_message)
    end

    Taxonomy::BulkPublishTaxon.call(ROOT_CONTENT_ID)
  rescue GdsApi::HTTPConflict, GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException => e
    error_message = "An error occurred while publishing taxons: #{e.message}"
    puts(error_message)
  rescue StandardError => e
    error_message = "An error occurred while publishing taxons: #{e.message}"
    puts(error_message)
  end
end
