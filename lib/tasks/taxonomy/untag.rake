require "gds_api/base"
namespace :taxonomy do
  desc "Untag all content tagged to a given taxon. (options: content_id of the taxon, 'untag' to untag)"
  task :untag, %i[content_id untag] => :environment do |_, args|
    taxon_content_id = args[:content_id]
    if taxon_content_id.nil?
      warn "Please supply the content id of the taxon to untag."
      next
    end

    GdsApi::Base.default_options = { timeout: 30 }

    content_list = Services.publishing_api.get_linked_items(args[:content_id], link_type: "taxons", fields: %w[content_id title]).to_a
    unique_content_list = content_list.uniq { |c| c["content_id"] }
    unique_content_list.each do |content|
      puts "Title #{content['title']}, content_id: #{content['content_id']}"
      Tagging::Untagger.call(content["content_id"], [taxon_content_id]) if args[:untag] == "untag"
    end
  end
end
