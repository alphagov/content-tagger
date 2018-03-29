desc "Perform taggings from a csv file"
task :tag_from_csv, [:csv_url] => :environment do |_, args|
  Tagging::CsvTagger.do_tagging(args[:csv_url]) do |tagging|
    puts "Tagging #{tagging[:content_id]} to [#{tagging[:taxon_ids].join(',')}]"
  end
end
