namespace :project do
  desc "Import a list of content items"
  task :import, %i[csv_url project_name] => :environment do |_, args|
    begin
      csv = RemoteCsv.new(args.csv_url)
      project = ProjectBuilder.call(args.project_name, csv.to_enum)
      puts "Created project #{project.name}; Imported #{project.content_items.size} Content Items"
    rescue StandardError => ex
      puts "Error; #{ex.message}"
    end
  end

  desc "Backfill content_ids for previously imported project content items"
  task fetch_content_ids: :environment do
    ProjectContentItem.where(content_id: nil).pluck(:id).each do |content_item_id|
      LookupContentIdWorker.perform_async(content_item_id)
    end
  end
end
