module AggregatableTagMappings
  extend ActiveSupport::Concern

  def aggregated_tag_mappings
    tag_mappings_grouped_by_content_base_path.reduce([]) do |accumulator, aggregation|
      accumulator << AggregatedTagMapping.new(content_base_path: aggregation.first, tag_mappings: aggregation.last)
    end
  end

private

  def tag_mappings_grouped_by_content_base_path
    tag_mappings.by_state.by_content_base_path.by_link_title
      .select(
        :link_type,
        :link_title,
        :content_base_path,
        :messages,
        :link_content_id,
        :state)
      .group_by(&:content_base_path)
  end
end
