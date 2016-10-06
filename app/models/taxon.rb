class Taxon
  ATTRIBUTES = %w(title
                  description
                  parent_taxons
                  child_taxons
                  content_id
                  base_path
                  publication_state
                  internal_name
                  notes_for_editors
                  document_type).freeze

  attr_accessor(*ATTRIBUTES)

  include ActiveModel::Model

  validates_presence_of :title

  def parent_taxons
    @parent_taxons ||= []
  end

  def content_id
    @content_id ||= SecureRandom.uuid
  end

  def base_path
    @base_path ||= '/alpha-taxonomy/' + SecureRandom.uuid + '-' + title.parameterize
  end

  def link_type
    'taxons'
  end
end
