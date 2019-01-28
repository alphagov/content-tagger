require 'gds_api/base'
namespace :content do
  desc "Updates suggested related links for content from a JSON file"
  task :update_related_links_from_json, [:json_path] => :environment do |_, args|
    file = File.read(args[:json_path])
    json = JSON.parse(file)
    @failed_content_ids = []

    json.each_pair do |source_content_id, related_content_ids|
      update_content(source_content_id: source_content_id, related_content_ids: related_content_ids)
    end

    puts "Failed content ids: #{@failed_content_ids}"
    puts "Retrying failed content updates..." if @failed_content_ids.any?

    @failed_content_ids.each do |source_content_id|
      puts "Retrying content id #{source_content_id} with related #{json[source_content_id]}"
      update_content(source_content_id: source_content_id, related_content_ids: json[source_content_id], retry_failed: false)
    end
  end

  def update_content(source_content_id:, related_content_ids:, retry_failed: true)
    Services.publishing_api.patch_links(
      source_content_id,
      links: {
        suggested_ordered_related_items: related_content_ids
      },
      bulk_publishing: true
    )

    puts "Updated related links for content #{source_content_id} to #{related_content_ids}"
  rescue GdsApi::HTTPErrorResponse => e
    STDERR.puts "Failed to update content id #{source_content_id} - response status #{e.code}"
  rescue GdsApi::TimedOutException
    STDERR.puts "Failed to update content id #{source_content_id} - connection to publishing API timed out"
    @failed_content_ids << source_content_id if retry_failed
  end
end
