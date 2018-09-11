module Tagging
  def self.blacklisted_document_types
    @blacklisted_document_types ||=
      YAML.load_file(
        File.join(
          Rails.root,
          'config',
          'document_types_excluded_from_the_topic_taxonomy.yml'
        )
      )['document_types']
  end
end
