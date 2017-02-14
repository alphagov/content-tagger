namespace :taxonomy do
  desc <<-DESC
    Prints the base paths of all taxons to STDOUT
  DESC
  task export: :environment do
    taxons = RemoteTaxons.new.search(per_page: 10_000).taxons

    taxons.each do |taxon|
      puts taxon.base_path
    end
  end
end
