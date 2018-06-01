require 'taxon_description_updater'
namespace :taxonomy do
  desc <<-DESC
    Clears all descriptions containing '...' or 'tbc'.
  DESC
  task clear_descriptions: [:environment] do
    TaxonDescriptionUpdater.new(%w[... tbc]).call
  end
end
