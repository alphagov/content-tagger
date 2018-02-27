namespace :content do
  desc "Find all content that is tagged to a taxon and its direct ancestor and optionally removes redundant tagging (option: untag='untag')"
  task :tagged_to_ancestor, [:untag] => :environment do |_, args|
    results = Tagging::CommonAncestorFinder.call
    results.each do |result|
      puts "Document #{result[:title]}, content_id: #{result[:content_id]} has common ancestors tagged to: "
      puts result[:common_ancestors].inspect
      Tagging::Untagger.call(result[:content_id], result[:common_ancestors]) if args[:untag] == "untag"
    end
  end
end
