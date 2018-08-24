require 'taxon_description_updater'
require 'description_remover'

namespace :taxonomy do
  desc <<-DESC
    Clears all descriptions containing '...' or 'tbc'.
  DESC
  task clear_descriptions: [:environment] do
    TaxonDescriptionUpdater.new(%w[... tbc TBC ...tbc]).call
  end

  desc <<-DESC
    Clears description from taxons children recursively.
  DESC
  task :clear_descriptions_for_branches, [:base_path] => [:environment] do |_, args|
    DescriptionRemover.call(args[:base_path])
  end
end
