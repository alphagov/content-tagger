class BulkTaggingSource
  def source_name_to_content_key_map
    {
      document_collection: 'documents',
      topic: 'children',
      mainstream_browse_page: 'children',
      taxon: 'taxon',
    }
  end

  def source_names
    source_name_to_content_key_map.keys
  end

  def content_key_for(source_name)
    content_key = source_name_to_content_key_map[source_name.to_sym]
    return content_key if content_key
    raise ArgumentError, "don't know how to handle bulk tagging source #{source_name}"
  end
end
