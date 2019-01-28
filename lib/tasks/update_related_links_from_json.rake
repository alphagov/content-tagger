require 'gds_api/base'
namespace :content do
  desc "Updates suggested related links for content from a JSON file"
  task :update_related_links_from_json, [:json_path] => :environment do |_, args|
    file = File.read(args[:json_path])
    json = JSON.parse(file)

    json.fetch('related_links', []).each do |content_to_update|
      next if content_to_update['target_content_ids'].empty?

      puts "Updating related links for content #{content_to_update['source_content_id']} to #{content_to_update['target_content_ids']}"

      Services.publishing_api.patch_links(
        content_to_update['source_content_id'],
        links: {
          suggested_ordered_related_items: content_to_update['target_content_ids']
        },
        bulk_publishing: true
      )
    end
  end
end
