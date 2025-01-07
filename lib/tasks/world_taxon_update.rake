# This task is to update the titles of each worldwide taxon to include the country name they relate to.
# This work is necessary to meet the following WCAG guidelines:
# https://www.w3.org/WAI/WCAG22/Understanding/page-titled.html
# https://www.w3.org/WAI/WCAG22/Techniques/failures/F25
# For accessibility reasons, taxon titles need to be more unique. Having multiple versions of pages for different
# countries all titled e.g. 'Trade and invest' goes against WCAG guidelines.

WORLD_ROOT_CONTENT_ID = "91b8ef20-74e7-4552-880c-50e6d73c2ff9".freeze

namespace :worldwide do
  desc "Update worldwide taxon titles (external name) to include the name of the country they relate to"

  task :add_country_name_to_title, %i[log_file_path] => :environment do |_, args|
    log_file = nil
    if args[:log_file_path]
      log_file = File.open(args[:log_file_path], "w")
      log_rake_progress(log_file, "Updating each worldwide taxon to include country name in their title")
    end

    total_taxon_updates = 0

    # Build a taxonomy tree with the grandparent
    # (common ancestor e.g. /world/all - Help and services around the world) as the root
    taxonomy = Taxonomy::ExpandedTaxonomy.new(WORLD_ROOT_CONTENT_ID).build.child_expansion
    log_rake_progress(log_file, "Taxonomy has size #{taxonomy.tree.size}")

    taxonomy.tree.each do |linked_item|
      # As this is a tree, we reach all grandchildren without another loop (not a nested array)
      # example grandchild url /world/passports-and-emergency-travel-documents-cape-verde

      next if skip_tree_item?(log_file, linked_item)

      message, new_title = create_new_taxon_title(linked_item.internal_name)
      log_rake_progress(log_file, message)

      # Fetch the taxon and update accordingly
      if new_title
        new_taxon = Taxonomy::BuildTaxon.call(content_id: linked_item.content_id)
        new_taxon.title = new_title

        # Save the taxon with the new title
        Taxonomy::UpdateTaxon.call(taxon: new_taxon)
        message = "Updated taxon #{linked_item.title} to #{new_title}"
      end
      log_rake_progress(log_file, message)
      total_taxon_updates += 1
    rescue Taxonomy::UpdateTaxon::InvalidTaxonError => e
      log_rake_error(log_file, "An error occurred while processing taxon #{linked_item.internal_name}: #{e.message}")
    end

    # Need to publish all the drafts we have created above (if latest edition is published)
    # - Draft editions are updated straight away.
    puts("Publishing all updated taxons")
    Taxonomy::BulkPublishTaxon.call(WORLD_ROOT_CONTENT_ID)
    log_rake_progress(log_file, "Total number of taxons updated - #{total_taxon_updates}")
  rescue GdsApi::HTTPConflict, GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException => e
    log_rake_error(log_file, "An error occurred while publishing taxons: #{e.full_message}")
  rescue StandardError => e
    log_rake_error(log_file, "An error occurred while publishing taxons: #{e.full_message}")
  ensure
    log_file&.close
  end

  # Necessary for testing before release to revert all changed titles back to their original state
  desc "Revert worldwide taxon titles (external name) to original text (remove the name of the country they relate to)"
  task :remove_country_name_from_title, %i[log_file_path] => :environment do |_, _args|
    log_file = nil
    if args[:log_file_path]
      log_file = File.open(args[:log_file_path], "w")
      log_rake_progress(log_file, "Reverting worldwide taxon titles to remove country name from their title")
    end

    taxonomy = Taxonomy::ExpandedTaxonomy.new(WORLD_ROOT_CONTENT_ID).build.child_expansion

    taxonomy.tree.each do |linked_item|
      next if skip_tree_item?(log_file, linked_item)

      title = linked_item.title
      suffix_index = nil
      if title.start_with?("Coming to the UK from")
        log_rake_progress(log_file, "removing - ...from COUNTRY_NAME from #{title}")
        suffix_index = title.index(" from ")
      elsif title.start_with?("Trade and invest:")
        log_rake_progress(log_file, "removing - ...: COUNTRY_NAME from #{title}")
        suffix_index = title.index(": ")
      elsif title.include?(" in ")
        log_rake_progress(log_file, "removing - ...in COUNTRY_NAME from #{title}")
        suffix_index = title.index(" in ")
      end

      next unless suffix_index

      new_title = title[0..(suffix_index - 1)]
      log_rake_progress(log_file, "New title = #{new_title}")

      new_taxon = Taxonomy::BuildTaxon.call(content_id: linked_item.content_id)
      new_taxon.title = new_title

      Taxonomy::UpdateTaxon.call(taxon: new_taxon)
    rescue Taxonomy::UpdateTaxon::InvalidTaxonError => e
      log_rake_error(log_file, "An error occurred while processing taxon #{internal_name}: #{e.message}")
    end

    Taxonomy::BulkPublishTaxon.call(WORLD_ROOT_CONTENT_ID)
  rescue GdsApi::HTTPConflict, GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException => e
    log_rake_error(log_file, "An error occurred while publishing taxons: #{e.message}")
  rescue StandardError => e
    log_rake_error(log_file, "An error occurred while publishing taxons: #{e.message}")
  end
end

private

def log_rake_progress(log_file, message)
  log_file&.puts(message)
  puts(message)
end

def log_rake_error(log_file, message)
  log_file&.puts(message)
  warn(message)
end

def create_new_taxon_title(internal_name)
  # -------------
  # Adding the appropriate suffix as follows:
  # Coming to the UK from COUNTRY_NAME
  # Trade and invest: COUNTRY_NAME
  # -------------
  # Birth, death and marriage abroad in COUNTRY_NAME
  # British embassy or high commission in COUNTRY_NAME
  # Emergency help for British nationals in COUNTRY_NAME
  # News and events in COUNTRY_NAME
  # Passports and emergency travel documents in COUNTRY_NAME
  # Tax, benefits, pensions and working abroad in COUNTRY_NAME
  # --------------

  new_title = ""
  if internal_name.start_with?("Coming to the UK")
    message = "adding - ...from COUNTRY_NAME"
    new_title = internal_name.gsub("(", "from ")
  elsif internal_name.start_with?("Trade and invest")
    message = "adding - ...: COUNTRY_NAME"
    new_title = internal_name.gsub(" (", ": ")
  else
    message = "adding - ...in COUNTRY_NAME"
    new_title = internal_name.gsub("(", "in ")
  end
  new_title.gsub!(")", "")
  [message, new_title]
end

def skip_tree_item?(log_file, linked_item)
  # Tree includes root (world/all) - skip that
  if linked_item.content_id == WORLD_ROOT_CONTENT_ID
    log_rake_progress(log_file, "Skipping world root taxon")
    return true
  end

  # Skip titles where the country name is already included at the end
  # e.g. If child - country pages (parent e.g. /world/argentina - UK help and services in Argentina)
  # or if the taxon is a GENERIC (template) version
  if linked_item.internal_name.start_with?("UK help and services in ") || linked_item.internal_name.start_with?("Living in ") ||
      linked_item.internal_name.start_with?("Travelling to ") || linked_item.internal_name.include?("(GENERIC)")
    log_rake_progress(log_file, "Skipping #{linked_item.internal_name}")
    return true
  end

  false
end
