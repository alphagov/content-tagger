class AggregatedTagMapping
  include ActiveModel::Model

  attr_accessor :content_base_path, :tag_mappings

  def links
    tag_mappings.map do |tag_mapping|
      Link.new(
        link_title: tag_mapping.link_title,
        link_content_id: tag_mapping.link_content_id,
        link_type: tag_mapping.link_type,
      )
    end
  end

  def completed?
    total_tag_mappings == completed_tag_mappings.size
  end

  def completed_tag_mappings
    tag_mappings.select { |mapping| TagMapping::COMPLETED_STATES.include?(mapping.state) }
  end

  def total_tag_mappings
    tag_mappings.size
  end

  class Link
    include ActiveModel::Model

    attr_accessor :link_title, :link_content_id, :link_type
  end
end
