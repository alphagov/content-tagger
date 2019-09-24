class TaxonDescriptionUpdater
  def initialize(descriptions_to_remove)
    @descriptions_to_remove = descriptions_to_remove
  end

  def call
    @descriptions_to_remove.each(&method(:replace_description))
  end

private

  EXCLUDE_ATTRIBUTES = %w[content_store user_facing_version publication_state lock_version updated_at state_history].freeze

  def replace_description(description_to_remove)
    content_items = publishing_api.get_content_items(
      per_page: 5000,
      q: description_to_remove,
      search_in: %w[description],
      states: %w[published draft],
    )
    content_items["results"].select { |item| item["description"] == description_to_remove }.each do |taxon|
      if taxon["publication_state"] == "published" && draft_version_exists?(taxon)
        puts "Published taxon: #{taxon_details(taxon)} draft has fixed description and cannot be amended"
        next
      end
      update_description(taxon, draft_version_exists?(taxon))
    end
  end

  def update_description(taxon, draft_version_exists)
    content_id = taxon["content_id"]
    payload = taxon.except(*EXCLUDE_ATTRIBUTES).merge(
      "description" => nil,
      "update_type" => "minor",
    )
    publishing_api.put_content(content_id, payload)
    publishing_api.publish(content_id) unless draft_version_exists
    log_what_happened(taxon, draft_version_exists)
  end

  def log_what_happened(taxon, draft_version_exists)
    if draft_version_exists
      puts "Draft taxon: #{taxon_details(taxon)} : description cleared but not published"
    else
      puts "Published taxon: #{taxon_details(taxon)} : description cleared and published"
    end
  end

  def taxon_details(taxon)
    "title: #{taxon['title']}, content_id: #{taxon['content_id']}"
  end

  def draft_version_exists?(taxon)
    taxon["state_history"].value?("draft")
  end

  def publishing_api
    @publishing_api ||= Services.publishing_api_with_long_timeout
  end
end
