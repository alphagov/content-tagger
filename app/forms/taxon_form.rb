class TaxonForm
  attr_accessor :title, :parent_taxons, :content_id, :base_path
  include ActiveModel::Model

  class InvalidTaxonError < StandardError; end

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

  def create!
    publish_taxon(presenter)
  rescue GdsApi::HTTPUnprocessableEntity => e
    Airbrake.notify(e)
    raise(InvalidTaxonError, I18n.t('errors.invalid_taxon'))
  end

private

  def presenter
    TaxonPresenter.new(base_path: base_path, title: title)
  end

  def publish_taxon(presenter)
    Services.publishing_api.put_content(content_id, presenter.payload)
    Services.publishing_api.publish(content_id, "minor")
    Services.publishing_api.patch_links(
      content_id,
      links: { parent_taxons: parent_taxons.select(&:present?) }
    )
  end
end
