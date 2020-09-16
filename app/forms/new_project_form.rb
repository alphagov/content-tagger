class NewProjectForm
  include ActiveModel::Model

  attr_accessor :name, :remote_url, :taxonomy_branch, :bulk_tagging_enabled
  alias_method :bulk_tagging_enabled?, :bulk_tagging_enabled

  UUID_REGEX = %r([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}).freeze

  validates_presence_of :name, :remote_url, :taxonomy_branch
  validates :remote_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :taxonomy_branch, format: { with: UUID_REGEX }

  def taxonomy_branches_for_select
    GovukTaxonomy::Branches.new.all
      .reduce({}) { |memo, branch| memo.merge(branch["title"] => branch["content_id"]) }
  end

  def generate
    return false unless valid?

    csv = RemoteCsv.new(remote_url)
    ProjectBuilder.call(
      content_item_attributes: csv.rows_with_headers,
      project_attributes: {
        name: name,
        taxonomy_branch: taxonomy_branch,
        bulk_tagging_enabled: bulk_tagging_enabled,
      },
    )

    true
  rescue RemoteCsv::ParsingError, ActiveModel::UnknownAttributeError => e
    errors[:remote_url] << e.message
    false
  rescue ProjectBuilder::DuplicateContentItemsError => e
    errors[:base] << [e.message, e.conflicting_items_urls]
    false
  end
end
