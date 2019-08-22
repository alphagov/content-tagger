require 'gds_api/base'
namespace :taxonomy do
  desc "Untag all content tagged to a given taxon. (options: content_id of the taxon, 'untag' to untag)"
  task :untag, %i[content_id untag] => :environment do |_, args|
    taxon_content_id = args[:content_id]
    if taxon_content_id.nil?
      puts "Please supply the content id of the taxon to untag."
      return
    end

    GdsApi::Base.default_options = { timeout: 30 }

    content_list = Services.publishing_api.get_linked_items(args[:content_id], link_type: 'taxons', fields: %w[content_id title]).to_a
    unique_content_list = content_list.uniq { |c| c['content_id'] }
    unique_content_list.each do |content|
      puts "Title #{content['title']}, content_id: #{content['content_id']}"
      Tagging::Untagger.call(content['content_id'], [taxon_content_id]) if args[:untag] == "untag"
    end
  end

  desc "Bulk untag documents, one row per document and tagging. (options: 'url': url of CSV)"
  task :bulk_untag, %i[content_id untag] => :environment do |_, args|
    untaggings = RemoteCsv.new(args[:url]).rows_with_headers
    untaggings.each do |content|
      puts "Untagging #{content['content_to_untag_base_path']} from #{content['current_taxon_name']}"
      Tagging::Untagger.call(content['content_id'], [content['current_taxon_content_id']])
    end
  end
end
