class FacetGroupImporter
  def initialize(import_file_path)
    @import_file_path = import_file_path
  end

  def import
    create_draft(:facet_group, facet_group_data)

    facet_group_data[:facets].each do |facet_data|
      create_draft(:facet, facet_data)

      facet_data[:facet_values].each do |facet_value_data|
        create_draft(:facet_value, facet_value_data)
      end
    end

    create_facet_group_links
  end

  def discard_draft_group
    discard_links(facet_group_data[:content_id], %i[facets])
    discard_draft(facet_group_data[:content_id])

    facet_group_data[:facets].each do |facet_data|
      discard_links(facet_data[:content_id], %i[facet_group facet_values])
      discard_draft(facet_data[:content_id])

      facet_data[:facet_values].each do |facet_value_data|
        discard_links(facet_value_data[:content_id], %i[facets])
        discard_draft(facet_value_data[:content_id])
      end
    end
  end

private

  attr_reader :import_file_path

  def create_draft(type, data)
    publishing_api.put_content(data[:content_id], send("#{type}_payload", data))
  end

  def discard_draft(content_id)
    publishing_api.discard_draft(content_id)
  end

  def discard_links(content_id, keys)
    empty_links = keys.each_with_object({}) { |key, hash| hash[key] = [] }
    publishing_api.patch_links(content_id, links_payload(empty_links))
  end

  def create_facet_group_links
    facets_data = facet_group_data[:facets]
    # Create the links for the facet group
    publishing_api.patch_links(facet_group_data[:content_id], facet_group_links_payload(facets_data))

    # Create the links for the facets
    facets_data.each do |facet|
      facet_values_data = facet[:facet_values]

      publishing_api.patch_links(facet[:content_id], facet_links_payload(facet_values_data))

      # Create the links for the facet values
      facet_values_data.each do |facet_value|
        publishing_api.patch_links(facet_value[:content_id], facet_value_links_payload(facet))
      end
    end
  end

  def facet_group_data
    @facet_group_data ||= YAML.load_file(import_file_path)
  end

  def publishing_api
    Services.publishing_api_with_long_timeout
  end

  def facet_group_payload(data)
    {
      document_type: "facet_group",
      schema_name: "facet_group",
      title: data[:title],
      details: {
        description: data[:description],
        name: data[:title],
      }
    }.merge(publishing_and_rendering_apps)
  end

  def facet_payload(data)
    {
      document_type: "facet",
      schema_name: "facet",
      title: data[:title],
      details: {
        filterable: true,
        key: data[:key],
        name: data[:title],
        type: "text",
      }
    }.merge(publishing_and_rendering_apps)
  end

  def facet_value_payload(data)
    {
      document_type: "facet_value",
      schema_name: "facet_value",
      title: data[:title],
      details: {
        label: data[:title],
        value: data[:value],
      }
    }.merge(publishing_and_rendering_apps)
  end

  def publishing_and_rendering_apps
    { publishing_app: "content-tagger", rendering_app: "finder-frontend" }
  end

  def facet_group_links_payload(facets)
    links_payload(facets: facets.map { |f| f[:content_id] })
  end

  def facet_links_payload(facet_values)
    links_payload(
      facet_values: facet_values.map { |v| v[:content_id] },
      parent: [facet_group_data[:content_id]],
    )
  end

  def facet_value_links_payload(facet)
    links_payload(parent: [facet[:content_id]])
  end

  def links_payload(links)
    { links: links }
  end
end
