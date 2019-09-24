require "csv"

module Taxonomy
  class TaxonomyExport
    COLUMNS = %w[
      title
      description
      content_id
      base_path
      document_type
      first_published_at
      public_updated_at
    ].freeze

    CSV_COLUMNS = COLUMNS + %w[primary_publishing_organisation]

    def initialize(content_id)
      @content_id = content_id
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << CSV_COLUMNS
        tagged_content.each do |tagged_item|
          csv << tagged_item.slice(*CSV_COLUMNS)
        end
      end
    end

  private

    def tagged_content
      linked_items.map do |item|
        add_primary_publishing_organisation(item)
      end
    end

    def add_primary_publishing_organisation(item)
      item.merge("primary_publishing_organisation" => primary_publishing_organisation_name(item["content_id"]))
    end

    def linked_items
      @linked_items ||= Services.publishing_api.get_linked_items(
        @content_id,
        link_type: "taxons",
        fields: COLUMNS,
      )
    end

    def tagged_content_ids
      linked_items.map do |content_item|
        content_item["content_id"]
      end
    end

    def links_for_tagged_content_ids
      links_for_content = {}
      tagged_content_ids.each_slice(1000) do |batch_content_ids|
        links_for_content.merge!(Services.publishing_api.get_links_for_content_ids(batch_content_ids).to_h)
      end
      links_for_content
    end

    def primary_organisation_ids
      links_for_tagged_content_ids.each_with_object({}) do |(content_id, links), result|
        result[content_id] = links.dig("links", "primary_publishing_organisation", 0)
      end
    end

    def primary_publishing_organisation_name(id)
      @tagged_content_organisation_names_cache ||= primary_organisation_ids.compact.each_with_object({}) do |(content_id, publishing_org_id), result|
        result[content_id] = organisations_cache[publishing_org_id]
      end
      @tagged_content_organisation_names_cache[id]
    end

    def all_organisations
      Services.publishing_api.get_content_items_enum(
        document_type: "organisation",
        fields: %w[content_id title],
        per_page: 600,
      )
    end

    def organisations_cache
      @organisations_cache ||= Hash[all_organisations.map { |org| [org["content_id"], org["title"]] }]
    end
  end
end
