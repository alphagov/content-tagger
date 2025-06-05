class ProjectContentItem < ApplicationRecord
  belongs_to :project, touch: true

  enum :flag, {
    needs_help: 1,
    missing_topic: 2,
  }

  validates :content_id, uniqueness: { allow_blank: true }

  attr_accessor :taxons

  def base_path
    url.gsub("https://www.gov.uk", "")
  end

  def done!
    update(done: true, flag: nil)
  end

  def proxied_url
    url.gsub(%r{https?://(www\.)?gov.uk/}, Proxies::IframeAllowingProxy::PROXY_BASE_PATH)
  end

  scope :done, -> { where(done: true) }
  scope :flagged_with, ->(flag) { where(flag: flags[flag]) }
  scope :flagged, -> { where.not(flag: nil) }
  scope :for_taxonomy_branch,
        (lambda do |branch_id|
           joins(:project).where("projects.taxonomy_branch = ?", branch_id)
         end)
  scope :matching_search, ->(query) { where("title ILIKE ?", "%#{sanitize_sql_like(query)}%") }
  scope :todo, -> { where(flag: nil, done: false) }
  scope :with_valid_ids, -> { where.not(content_id: nil) }
end
