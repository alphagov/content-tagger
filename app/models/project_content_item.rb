class ProjectContentItem < ActiveRecord::Base
  belongs_to :project

  def base_path
    url.gsub('https://www.gov.uk', '')
  end

  # taxons don't exist
  def taxons
    []
  end

  def mark_complete
    update_attributes(done: true)
  end

  def proxied_url
    url.gsub(%r{https?://(www\.)?gov.uk/}, Proxies::IframeAllowingProxy::PROXY_BASE_PATH)
  end

  scope :uncompleted, -> { where(done: false) }
  scope :matching_search, -> (query) { where("title LIKE ?", "%#{query}%") }
  scope :with_valid_ids, -> { where.not(content_id: nil) }
end
