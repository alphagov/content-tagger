class TaggingProgressByOrganisationsQuery
  def initialize(organisations)
    @organisations = organisations
  end

  def percentage_tagged
    @_tagged_counts ||= content_item_counts_grouped_by_organisation.transform_values do |results|
      total_count, tagged_count = results.map { |obj| obj["documents"] }
      {
        percentage: percentage(tagged_count, total_count),
        total: total_count,
        tagged: tagged_count
      }
    end
  end

  def total_counts
    return {} if percentage_tagged.empty?
    total_count = percentage_tagged.values.map { |v| v[:total] }.sum
    tagged_count = percentage_tagged.values.map { |v| v[:tagged] }.sum
    {
      percentage: percentage(tagged_count, total_count),
      total: total_count,
      tagged: tagged_count
    }
  end

private

  attr_reader :organisations

  def percentage(tagged_count, total_count)
    return 0.0 if total_count.zero?
    (Float(tagged_count) / Float(total_count)) * 100
  end

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
      filter_part_of_taxonomy_tree: Taxonomy::LevelOneTaxonsRetrieval.new.get.map { |t| t['content_id'] },
    ).to_h.dig("aggregates", "primary_publishing_organisation", "options")
  end
end
