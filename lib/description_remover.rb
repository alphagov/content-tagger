class DescriptionRemover
  def initialize(base_path)
    @base_path = base_path
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    taxon_ids = child_taxon_ids(base_path)
    taxons_with_no_draft = published_taxons_with_no_drafts(taxons(taxon_ids))

    clear_descriptions(taxons_with_no_draft)
  end

private

  attr_reader :base_path

  EXCLUDE_ATTRIBUTES = %w[content_store user_facing_version publication_state lock_version updated_at state_history].freeze

  def child_taxon_ids(base_path)
    Taxonomy::TaxonomyQuery.new.child_taxons(base_path).pluck("content_id")
  end

  def taxons(taxon_ids)
    taxon_ids.map do |id|
      Services.publishing_api.get_content(id).to_h
    end
  end

  def published_taxons_with_no_drafts(taxons)
    taxons.reject do |taxon|
      taxon["state_history"].value?("draft")
    end
  end

  def clear_descriptions(taxons_with_no_draft)
    taxons_with_no_draft.each do |taxon|
      content_id = taxon["content_id"]
      payload = taxon.except(*EXCLUDE_ATTRIBUTES).merge(
        "description" => nil,
        "update_type" => "minor",
      )

      Services.publishing_api.put_content(content_id, payload)
      Services.publishing_api.publish(content_id)
      puts "Description cleared for taxon: #{taxon['title']}"
    end
  end
end
