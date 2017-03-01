require 'gds_api/rummager'
require 'gds_api/content_store'

namespace :find_withdrawn do
  desc <<-DESC
    Fetch all mainstream browse pages and ensure that their mainstream content is valid
  DESC
  task mainstream_browse_pages: :environment do
    mainstream_browse_pages = GdsApi::Rummager.new(Plek.find('rummager'))
      .search(
        filter_format: 'mainstream_browse_page',
        count: 1000,
      )['results']

    results = {}

    mainstream_browse_pages.each do |page|
      slug = page['slug']
      rummager_content = GdsApi::Rummager.new(Plek.find('rummager'))
        .search(
          filter_mainstream_browse_pages: [slug],
          fields: ['content_id'],
          count: 1000,
        )['results']
      rummager_paths = rummager_content.map { |content| content['_id'] }

      base_path = page['link']
      content_store_content = GdsApi::ContentStore.new(Plek.find('content-store'))
        .content_item(base_path)
        .dig('links', 'mainstream_browse_content') || []
      content_store_paths = content_store_content.map { |content| content['base_path'] }

      results[base_path] = {
        rummager: rummager_paths,
        content_store: content_store_paths,
      }
    end

    paths_not_in_rummager = []
    paths_not_in_content_store = []

    results.each_pair do |browse_page_base_path, content_base_paths|
      rummager_paths = content_base_paths[:rummager]
      content_store_paths = content_base_paths[:content_store]

      puts "#{browse_page_base_path} : #{rummager_paths.length} in Rummager, #{content_store_paths.length} in Content Store"

      not_in_rummager = content_store_paths - rummager_paths
      not_in_content_store = rummager_paths - content_store_paths

      unless not_in_rummager.empty?
        not_in_rummager.each { |item| paths_not_in_rummager << item }
      end

      unless not_in_content_store.empty?
        not_in_content_store.each { |item| paths_not_in_content_store << item }
      end

      puts "#{not_in_rummager.length} not in Rummager, #{not_in_content_store.length} not in Content Store"
    end

    puts "\n\n#{paths_not_in_rummager.length} PATHS NOT FOUND IN RUMMAGER:"
    paths_not_in_rummager.each { |id| puts id }

    puts "\n\n#{paths_not_in_content_store.length} PATHS NOT FOUND IN CONTENT STORE:"
    paths_not_in_content_store.each { |id| puts id }
  end
end
