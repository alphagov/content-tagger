class Taxon
  attr_accessor(
    :title,
    :description,
    :parent_content_id,
    :path_prefix,
    :path_slug,
    :publication_state,
    :phase,
    :document_type,
    :redirect_to,
    :associated_taxons
  )
  attr_writer :content_id, :notes_for_editors, :internal_name

  include ActiveModel::Model

  validates_presence_of :title, :description, :internal_name, :path_slug
  validates_presence_of :path_prefix, if: :level_one_taxon?
  validates :path_slug, format: { with: %r{\A[A-z0-9\-]+\z}, message: "path must not contain /" }
  validates_with CircularDependencyValidator

  def draft?
    publication_state == "draft"
  end

  def published?
    publication_state == "published"
  end

  def unpublished?
    publication_state == "unpublished"
  end

  def redirected?
    publication_state == "unpublished" && !redirect_to.nil?
  end

  def level_one_taxon?
    parent_content_id.present? &&
      parent_content_id == GovukTaxonomy::ROOT_CONTENT_ID
  end

  def content_id
    @content_id ||= SecureRandom.uuid
  end

  def base_path=(base_path)
    @base_path = base_path

    path_components = %r{^\/(?<prefix>[A-z0-9\-]+)(\/(?<slug>[A-z0-9\-]+))?$}.match(base_path)

    return if path_components.nil?

    @path_prefix = path_components['prefix']
    @path_slug = path_components['slug']
  end

  def base_path
    if [path_prefix, path_slug].any?
      '/' + [path_prefix, path_slug].compact.join('/')
    else
      @base_path
    end
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

  # Lets talk about this.
  #
  # This model takes data in either formencoded or JSON formats:
  #  - the Rails form submission gives us stringified data
  #  - the JSON API response gives us true booleans.
  # In an ideal world we wouldn't have to worry about this
  # but ActiveModel doesn't have decent type coercion yet.
  def visible_to_departmental_editors=(val)
    @visible_to_departmental_editors = (val.to_s == 'true')
  end

  def visible_to_departmental_editors
    @visible_to_departmental_editors || false
  end
end
