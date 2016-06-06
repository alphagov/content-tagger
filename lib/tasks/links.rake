namespace :links do
  # Currently we disable tagging for certain publishing apps and link types
  # in content tagger to avoid conflicting data, because those apps have
  # their own data store rather than relying on publishing api as the source
  # of truth.
  #
  # These tasks exist to correct any inconsistencies with this content without
  # needing a full republish.

  desc "Send a comma seperated set of organisation links to the publishing API. Use with caution."
  task send_organisations: :environment do
    content_id = ENV.fetch("CONTENT_ID")
    organisation_ids = ENV.fetch("ORGANISATION_IDS").split(",")
    links = { organisations: organisation_ids }

    puts "Updating #{content_id}: #{links}"

    Services.publishing_api.patch_links(content_id, links: links)
  end
end
