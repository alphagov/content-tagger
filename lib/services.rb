require 'gds_api/publishing_api_v2'
require 'gds_api/panopticon'
require 'gds_api/rummager'
require 'gds_api/content_store'

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
  end

  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(
      Plek.new.find('content-store'),
      disable_cache: true
    )
  end

  def self.panopticon
    @panopticon ||= GdsApi::Panopticon.new(
      Plek.new.find('panopticon'),
      disable_cache: true,
      bearer_token: ENV['PANOPTICON_BEARER_TOKEN'] || 'example'
    )
  end

  def self.rummager
    @rummager ||= GdsApi::Rummager.new(
      Plek.new.find('rummager'),
      disable_cache: true
    )
  end
end

class GdsApi::Panopticon < GdsApi::Base
  def delete_tag!(tag_type, tag_id)
    delete_json!(tag_url(tag_type, tag_id))
  end
end
