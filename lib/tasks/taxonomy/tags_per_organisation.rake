require 'csv'
require_relative Rails.root.join('lib', 'tagged_content_exporter')

namespace :taxonomy do
  desc <<-DESC
    saves the number of tags to taxons per organisation in a set of CSV files.
  DESC
  task :tags_per_organisation, %i[path] => :environment do |_, args|
    path = args[:path]
    FileUtils.mkdir_p path
    Taxonomy::OrganisationCount.new.all_taggings_per_organisation.each do |result|
      csv_file_path = "#{path}/#{result[:title].parameterize}.csv"
      puts csv_file_path
      CSV.open(csv_file_path, "wb") do |csv|
        result[:sheet].each { |row| csv << row }
      end
    end
  end
end
