class Taxon
  attr_accessor(
    :title,
    :description,
    :parent_taxons,
    :content_id,
    :base_path,
    :path_prefix,
    :path_slug,
    :publication_state,
    :internal_name,
    :notes_for_editors,
    :document_type
  )

  include ActiveModel::Model

  validates_presence_of :title, :description, :internal_name, :path_prefix
  validates :path_prefix, inclusion: { in: Theme.taxon_path_prefixes }
  validates :path_slug, allow_blank: true, format: { with: %r{\A/[a-zA-Z0-9\-]+\z} }
  validates_with CircularDependencyValidator

  def parent_taxons
    @parent_taxons ||= []
  end

  def theme
    Theme::THEMES[path_prefix] || "Other"
  end

  def draft?
    publication_state == "draft"
  end

  def published?
    publication_state == "published"
  end

  def unpublished?
    publication_state == "unpublished"
  end

  def publication_state_name
    {
      "draft" => "Draft",
      "published" => "Published",
      "unpublished" => "Deleted",
    }.fetch(publication_state)
  end

  def content_id
    @content_id ||= SecureRandom.uuid
  end

  def base_path=(base_path)
    path_components = %r{(?<prefix>/[^/]+)(?<slug>/.+)?}.match(base_path)

    unless path_components.nil?
      @path_prefix = path_components['prefix']
      @path_slug = path_components['slug']
    end
  end

  def base_path
    @base_path ||= path_prefix + path_slug
  end

  def path_prefix
    @path_prefix ||= ''
  end

  def path_slug
    @path_slug ||= ''
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
