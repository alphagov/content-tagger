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
      search_in: ['description']
    )
    content_items['results'].select { |item| item['description'] == description_to_remove }.each do |taxon|
      update_description(taxon, draft_version_exists?(taxon))
    end
  end

  def update_description(taxon, draft_version_exists)
    content_id = taxon['content_id']
    payload = taxon.except(*EXCLUDE_ATTRIBUTES).merge(
      'description' => nil,
      'update_type' => 'minor'
    )
    publishing_api.put_content(content_id, payload)
    publishing_api.publish(content_id) unless draft_version_exists
  end

  def draft_version_exists?(taxon)
    taxon['state_history'].values.include? 'draft'
  end

  def publishing_api
    @publishing_api ||= Services.publishing_api_with_long_timeout
  end
end
