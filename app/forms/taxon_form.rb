class TaxonForm
  attr_accessor :title, :parent_taxons, :content_id, :base_path
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
end
