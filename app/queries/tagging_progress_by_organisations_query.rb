class TaggingProgressByOrganisationsQuery
  def initialize(organisations)
    @organisations = organisations
  end

  def percentage_tagged
    content_item_counts_grouped_by_organisation.transform_values do |results|
      total_count, tagged_count = results.map { |obj| obj["documents"] }
      (Float(tagged_count) / Float(total_count)) * 100
    end
  end

private

  attr_reader :organisations

  def content_item_counts_grouped_by_organisation
    (Array(total_content_count) + Array(tagged_content_count))
      .group_by { |obj| obj["value"]["slug"] }
  end

  def total_content_count
    Services.rummager.search(
      count: 0,
      start: 0,
      aggregate_primary_publishing_organisation: '0,scope:all_filters',
      filter_primary_publishing_organisation: organisations,
    ).to_h.dig("aggregates", "primary_publishing_organisation", "options")
  end

  def tagged_content_count
    Services.rummager.search(
      count: 0,
      start: 0,
      aggregate_primary_publishing_organisation: '0,scope:all_filters',
      filter_primary_publishing_organisation: organisations,
      reject_taxons: '_MISSING',
    ).to_h.dig("aggregates", "primary_publishing_organisation", "options")
  end
end
