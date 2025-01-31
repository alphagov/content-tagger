# frozen_string_literal: true

class WorldTaxonUpdateHelper
  def initialize(log_file)
    @log_file = log_file
  end

  def add_country_names
    log_rake_progress("Updating each worldwide taxon to include country name in their title")
    total_taxon_updates = 0

    # Build a taxonomy tree with the grandparent
    # (common ancestor e.g. /world/all - Help and services around the world) as the root
    taxonomy = Taxonomy::ExpandedTaxonomy.new(WORLD_ROOT_CONTENT_ID).build.child_expansion
    log_rake_progress("Taxonomy has size #{taxonomy.tree.size}")

    taxonomy.tree.each do |linked_item|
      # As this is a tree, we reach all grandchildren without another loop (not a nested array)
      # example grandchild url /world/passports-and-emergency-travel-documents-cape-verde

      next if skip_tree_item?(linked_item)

      new_title = create_title_adding_country_name(linked_item.internal_name)
      next if new_title == linked_item.title

      # Fetch the taxon and update accordingly
      new_taxon = Taxonomy::BuildTaxon.call(content_id: linked_item.content_id)
      new_taxon.title = new_title

      # Save the taxon with the new title
      Taxonomy::UpdateTaxon.call(taxon: new_taxon)
      message = "Updated taxon #{linked_item.title} to #{new_title}"

      log_rake_progress(message)
      total_taxon_updates += 1
    rescue StandardError => e
      log_rake_error("An error occurred while processing taxon #{linked_item.internal_name}: #{e.message}")
      raise
    end

    # Need to publish all the drafts we have created above (if latest edition is published)
    # - Draft editions are updated straight away.
    log_rake_progress("Publishing all updated taxons")
    Taxonomy::BulkPublishTaxon.call(WORLD_ROOT_CONTENT_ID)
    log_rake_progress("Total number of taxons updated - #{total_taxon_updates}")
  rescue StandardError => e
    log_rake_error("An error occurred while publishing taxons: #{e.full_message}")
  end

  def remove_country_names
    log_rake_progress("Updating each worldwide taxon to remove the country name from their title")
    total_taxon_updates = 0
    taxonomy = Taxonomy::ExpandedTaxonomy.new(WORLD_ROOT_CONTENT_ID).build.child_expansion
    log_rake_progress("Taxonomy has size #{taxonomy.tree.size}")

    taxonomy.tree.each do |linked_item|
      next if skip_tree_item?(linked_item)

      title = linked_item.title
      new_title = create_title_removing_country_name(title)

      next if title == new_title

      new_taxon = Taxonomy::BuildTaxon.call(content_id: linked_item.content_id)
      new_taxon.title = new_title

      Taxonomy::UpdateTaxon.call(taxon: new_taxon)
      message = "Updated taxon #{linked_item.title} to #{new_title}"

      log_rake_progress(message)
      total_taxon_updates += 1
    rescue StandardError => e
      log_rake_error("An error occurred while processing taxon #{linked_item.internal_name}: #{e.message}")
      raise
    end

    log_rake_progress("Publishing all updated taxons")
    Taxonomy::BulkPublishTaxon.call(WORLD_ROOT_CONTENT_ID)
    log_rake_progress("Total number of taxons updated - #{total_taxon_updates}")
  rescue StandardError => e
    log_rake_error("An error occurred while publishing taxons: #{e.full_message}")
  end

private

  def log_rake_progress(message)
    @log_file&.puts(message)
    puts(message)
  end

  def log_rake_error(message)
    @log_file&.puts(message)
    warn(message)
  end

  def create_title_adding_country_name(internal_name)
    # -------------
    # Takes the country name from the internal_name and adds it to the title
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
    # Example:
    # internal_name = 'Coming to the UK (Argentina)'
    # title = 'Coming to the UK'
    # Becomes:
    # new_title = 'Coming to the UK from Argentina'

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

    log_rake_progress(message)
    log_rake_progress("New title: #{new_title}")

    new_title
  end

  def create_title_removing_country_name(title)
    # -------------
    # Takes the country name from the title and removes it
    # Removing the appropriate suffix to leave the title as it was
    # prior to the COUNTRY_NAME being added
    # --------------
    # Example:
    # title = 'Coming to the UK from Argentina'
    # new_title = 'Coming to the UK'

    suffix_index = nil
    if title.start_with?("Coming to the UK from")
      message = "removing - ...from COUNTRY_NAME from #{title}"
      suffix_index = title.index(" from ")
    elsif title.start_with?("Trade and invest:")
      message = "removing - ...: COUNTRY_NAME from #{title}"
      suffix_index = title.index(": ")
    elsif title.include?(" in ")
      message = "removing - ...in COUNTRY_NAME from #{title}"
      suffix_index = title.index(" in ")
    end
    log_rake_progress(message)

    if suffix_index.nil?
      log_rake_progress("No change to title: #{title}")
      return title
    end

    new_title = title[0..(suffix_index - 1)]
    log_rake_progress("New title: #{new_title}")
    new_title
  end

  def skip_tree_item?(linked_item)
    # Tree includes root (world/all) - skip that
    if linked_item.content_id == WORLD_ROOT_CONTENT_ID
      log_rake_progress("Skipping world root taxon")
      return true
    end

    # Skip internal names where the country name is already included at the end
    # e.g. If child - country pages (parent e.g. /world/argentina - UK help and services in Argentina)
    # or if the taxon is a GENERIC (template) version
    if linked_item.internal_name.start_with?("UK help and services in ", "Living in ", "Travelling to ") \
      || linked_item.internal_name.include?("(GENERIC)")
      log_rake_progress("Skipping #{linked_item.internal_name}")
      return true
    end

    false
  end
end
