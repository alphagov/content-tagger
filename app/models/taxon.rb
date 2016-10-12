class Taxon
  attr_accessor(
    :title,
    :description,
    :parent_taxons,
    :content_id,
    :base_path,
    :publication_state,
    :internal_name,
    :notes_for_editors,
    :document_type
  )

  include ActiveModel::Model

  validates_presence_of :title, :internal_name

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

  def internal_name
    @internal_name || @title
  end

  def notes_for_editors
    @notes_for_editors || ""
  end
end
