require "csv"

class FacetDataTagger
  attr_reader :facet_data, :logger, :paths_mapped_to_content_ids

  def initialize(data_file_path, facet_config_file_path, logger = Logger.new(STDOUT))
    @facet_config_file_path = facet_config_file_path
    @facet_data = {}
    @logger = logger

    CSV.foreach(data_file_path, converters: ->(v) { v || "" }) do |row|
      base_path = row[0]

      facet_data_for_path = facet_values_for_row(row)

      @facet_data[base_path] = facet_data_for_path
    end

    @paths_mapped_to_content_ids = publishing_api.lookup_content_ids(
      base_paths: @facet_data.keys,
      with_drafts: true,
    )
  end

  # Patches facet_values links for each content item denoted by base path
  # in the facet data.
  #
  def link_content_to_facet_values
    facet_data.each do |base_path, facet_data|
      content_id = content_id_for_base_path(base_path)
      next unless content_id

      publishing_api.patch_links(
        content_id,
        links: {
          facet_groups: [facet_group_config[:content_id]],
          facet_values: facet_data,
        },
      )
      logger.info "Patched #{content_id} with links:"
      logger.info "facet_groups: [#{facet_group_config[:content_id]}], facet_values: [#{facet_data.join(',')}]"
    end
  end

  # Patches empty facet_values links for the content items
  # at the relevant base paths
  #
  def remove_all_facet_data_for_base_paths(base_paths)
    base_paths = Array(base_paths)

    base_paths.each do |base_path|
      content_id = content_id_for_base_path(base_path)
      next unless content_id

      publishing_api.patch_links(
        content_id,
        links: {
          facet_groups: [],
          facet_values: [],
        },
      )
      logger.info "Patched empty facet_groups and facet_values links for #{content_id}"
    end
  end

private

  def facets_from_config
    facet_group_config[:facets]
  end

  def content_id_for_base_path(base_path)
    paths_mapped_to_content_ids[base_path]
  end

  # Creates a hash of arrays where the key is the facet name
  # and the value is an array of facet_value content_ids
  #
  def facet_values_for_row(row)
    facet_values = []
    facets_from_config.each_with_index do |facet, index|
      row_index = index + 1
      stripped_row_data = row.fetch(row_index, "").split(",").map(&:strip)
      facet_values << stripped_row_data.map { |v| facet[:facet_values].find { |fv| fv[:value] == v } }
    end
    facet_values.flatten.compact.map { |fv| fv[:content_id] }
  end

  def facet_group_config
    @facet_group_config ||= YAML.load_file(@facet_config_file_path)
  end

  def publishing_api
    Services.publishing_api_with_long_timeout
  end
end
