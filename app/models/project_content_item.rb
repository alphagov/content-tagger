class ProjectContentItem < ActiveRecord::Base
  belongs_to :project

  enum flag: {
    needs_help: 1,
    missing_topic: 2,
  }

  attr_accessor :taxons

  def base_path
    url.gsub('https://www.gov.uk', '')
  end

  def done!
    update_attributes(done: true, flag: nil)
  end

  def proxied_url
    url.gsub(%r{https?://(www\.)?gov.uk/}, Proxies::IframeAllowingProxy::PROXY_BASE_PATH)
  end

  scope :uncompleted, -> { where(done: false) }
  scope :matching_search, -> (query) { where("title ILIKE ?", "%#{query}%") }
  scope :with_valid_ids, -> { where.not(content_id: nil) }

  scope :for_taxonomy_branch, (lambda do |branch_id|
    joins(:project).where("projects.taxonomy_branch = ?", branch_id)
  end)

  scope :flagged_with, -> (flag) { where(flag: flags[flag]) }

  scope :todo, -> { where(flag: nil, done: false) }
  scope :flagged, -> { where.not(flag: nil) }
  scope :done, -> { where(done: true) }
end
