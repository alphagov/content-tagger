class NewProjectForm
  include ActiveModel::Model

  attr_accessor :name, :remote_url, :taxonomy_branch, :bulk_tagging_enabled
  alias bulk_tagging_enabled? bulk_tagging_enabled

  UUID_REGEX = %r([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})

  validates_presence_of :name, :remote_url, :taxonomy_branch
  validates :remote_url, format: URI.regexp(%w(http https))
  validates :taxonomy_branch, format: { with: UUID_REGEX }

  def taxonomy_branches_for_select
    GovukTaxonomy::Branches.new.all
      .select { |branch| branch['status'] == 'draft' }
      .reduce({}) { |memo, branch| memo.merge(branch['title'] => branch['content_id']) }
  end

  def create
    return false unless valid?
    csv = RemoteCsv.new(remote_url)
    ProjectBuilder.call(
      name: name,
      taxonomy_branch_content_id: taxonomy_branch,
      content_item_attributes_enum: csv.to_enum,
      bulk_tagging_enabled: bulk_tagging_enabled
    )
  rescue URI::InvalidURIError,
         ActiveRecord::RecordInvalid,
         Errno::ECONNREFUSED,
         CSV::MalformedCSVError,
         ActiveModel::UnknownAttributeError,
         SocketError => ex
    errors[:remote_url] << ex.message
    false
  end
end
