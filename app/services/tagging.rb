module Tagging
  def self.denylisted_document_types
    @denylisted_document_types ||=
      YAML.load_file(
        Rails.root.join("config/document_types_excluded_from_the_topic_taxonomy.yml"),
      )["document_types"]
  end
end
