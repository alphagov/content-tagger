namespace :project do
  desc "Import a list of content items"
  task :import, %i(csv_url project_name) => :environment do |_, args|
    begin
      csv = RemoteCsv.new(args.csv_url)
      project = ProjectBuilder.call(args.project_name, csv.to_enum)
      puts "Created project #{project.name}; Imported #{project.content_items.size} Content Items"
    rescue => ex
      puts "Error; #{ex.message}"
    end
  end
end
