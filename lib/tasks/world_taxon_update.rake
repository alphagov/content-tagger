# This task is to update the titles of each worldwide taxon to include the country name they relate to.
# This work is necessary to meet the following WCAG guidelines:
# https://www.w3.org/WAI/WCAG22/Understanding/page-titled.html
# https://www.w3.org/WAI/WCAG22/Techniques/failures/F25
# For accessibility reasons, taxon titles need to be more unique. Having multiple versions of pages for different
# countries all titled e.g. 'Trade and invest' goes against WCAG guidelines.

require "world_taxon_update_helper"
WORLD_ROOT_CONTENT_ID = "91b8ef20-74e7-4552-880c-50e6d73c2ff9".freeze

namespace :worldwide do
  desc "Update worldwide taxon titles (external name) to include the name of the country they relate to"

  task :add_country_name_to_title, %i[log_file_path] => :environment do |_, args|
    log_file = nil
    log_file_path = args[:log_file_path]
    if log_file_path
      log_file = File.open(log_file_path, "w")
    end

    WorldTaxonUpdateHelper.new(log_file).add_country_names
  rescue StandardError => e
    warn e.full_message
  ensure
    log_file&.close
  end

  # Necessary for testing before release to revert all changed titles back to their original state
  desc "Revert worldwide taxon titles (external name) to original text (remove the name of the country they relate to)"
  task :remove_country_name_from_title, %i[log_file_path] => :environment do |_, args|
    log_file = nil
    log_file_path = args[:log_file_path]
    if log_file_path
      log_file = File.open(log_file_path, "w")
    end

    WorldTaxonUpdateHelper.new(log_file).remove_country_names
  rescue StandardError => e
    warn e.full_message
  ensure
    log_file&.close
  end
end
