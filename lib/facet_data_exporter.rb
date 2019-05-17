require "csv"

class FacetDataExporter
  attr_reader :logger

  def initialize(facet_group_content_id, data_file_path, facet_config_file_path, logger = Logger.new(STDOUT))
    @facet_group_content_id = facet_group_content_id
    @data_file_path = data_file_path
    @facet_config_file_path = facet_config_file_path
    @logger = logger
  end

  def export
    logger.info("Writing facet tagging data to #{@data_file_path}")
    CSV.open(@data_file_path, "wb") do |csv|
      facet_values_for_content_items.each do |base_path, facet_value_data|
        next unless facet_value_data

        row = facet_value_data.unshift(base_path)
        logger.info row.join(" | ")
        csv << row
      end
    end
  end

private

  attr_reader :facet_group_content_id

  def facet_values_for_content_items
    {}.tap do |hash|
      content_items_linked_to_facet_group.each do |content_item|
        response = publishing_api.get_links(content_item["content_id"])
        facet_values_links = response.to_hash.fetch("links", {})["facet_values"]
        next unless facet_values_links

        tags = facet_values_tags(facet_values_links)
        hash[content_item["base_path"]] = tags
      end
    end
  end

  def facet_values_tags(content_ids)
    [].tap do |ary|
      facet_group_config[:facets].each do |facet|
        facet_values = facet[:facet_values]
        ary << facet_values
          .select { |fv| content_ids.include?(fv[:content_id]) }
          .map { |fv| fv[:value] }
          .sort
          .join(",")
      end
    end
  end

  def content_items_linked_to_facet_group
    publishing_api.get_linked_items(
      facet_group_content_id, link_type: "facet_groups", fields: %w[content_id base_path document_type]
    ).to_hash
  end

  def facet_group_config
    @facet_group_config ||= YAML.load_file(@facet_config_file_path)
  end

  def publishing_api
    Services.publishing_api
  end
end
