namespace :travel_advice do
  desc "Tag a travel advice edition to an organisation"
  task :tag_edition_to_organisation, %i[content_id org_id] => :environment do |_, args|
    content_id = args.content_id
    org_id = args.org_id

    Tagging::Tagger.add_tags(content_id, [org_id], :organisations)
  end

  desc "Tag all published travel advice editions to an organisation"
  task :tag_editions_to_organisation, %i[org_id] => :environment do |_, args|
    org_id = args.org_id
    response = Services.publishing_api.get_editions(
      per_page: 300,
      publishing_app: "travel-advice-publisher",
      document_types: %w[travel_advice],
      states: %w[published],
    )

    response["results"].each do |edition|
      Tagging::Tagger.add_tags(edition["content_id"], [org_id], :organisations)
    end
  end
end
