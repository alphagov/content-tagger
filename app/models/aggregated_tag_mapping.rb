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

  class Link
    include ActiveModel::Model

    attr_accessor :link_title, :link_content_id, :link_type
  end
end
