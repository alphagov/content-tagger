class Taxon
  # rubocop:disable Lint/MixedRegexpCaptureTypes
  PATH_COMPONENTS_REGEX = %r{\A/(?<prefix>[A-z0-9\-]+)(/(?<slug>[A-z0-9\-]+))?\z}.freeze
  # rubocop:enable Lint/MixedRegexpCaptureTypes

  attr_accessor(
    :title,
    :description,
    :parent_content_id,
    :publication_state,
    :state_history,
    :phase,
    :document_type,
    :redirect_to,
    :associated_taxons,
  )
  attr_writer :content_id, :notes_for_editors, :internal_name, :url_override
  attr_reader :base_path, :path_prefix, :path_slug, :legacy_taxons

  include ActiveModel::Model

  validates :title, :internal_name, :base_path, presence: true
  validates_with CircularDependencyValidator
  validates :base_path, format: { with: PATH_COMPONENTS_REGEX, message: "must be in the format '/highest-level-taxon-name/taxon-name'" }
  validates :url_override, format: { with: PATH_COMPONENTS_REGEX, message: "must be in the format '/prefix/slug' or '/slug'" }, allow_blank: true
  validates_with TaxonPathPrefixValidator

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

  def draft_and_published_editions_exist?
    previous_state, latest_state = lastest_two_publication_states
    previous_state && latest_state == "draft"
  end

  def ordered_publication_state_history
    state_history.sort_by(&:first).map(&:second)
  end

  def lastest_two_publication_states
    ordered_publication_state_history.last(2)
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

    path_components = PATH_COMPONENTS_REGEX.match(base_path)

    return if path_components.nil?

    @path_prefix = path_components["prefix"]
    @path_slug = path_components["slug"]
  end

  def legacy_taxons=(legacy_taxons)
    @legacy_taxons = legacy_taxons.select(&:present?)
  end

  def link_type
    "taxons"
  end

  def internal_name
    @internal_name || @title
  end

  def notes_for_editors
    @notes_for_editors || ""
  end

  def url_override
    @url_override || ""
  end

  # Lets talk about this.
  #
  # This model takes data in either formencoded or JSON formats:
  #  - the Rails form submission gives us stringified data
  #  - the JSON API response gives us true booleans.
  # In an ideal world we wouldn't have to worry about this
  # but ActiveModel doesn't have decent type coercion yet.
  def visible_to_departmental_editors=(val)
    @visible_to_departmental_editors = (val.to_s == "true")
  end

  def visible_to_departmental_editors
    @visible_to_departmental_editors || false
  end
end
