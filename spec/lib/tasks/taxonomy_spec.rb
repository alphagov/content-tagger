require 'rails_helper'
require 'rake'

RSpec.describe 'taxonomy rake task' do
  describe 'taxonomy:rename_base_paths' do
    before do
      load './lib/tasks/taxonomy.rake'
      Rake::Task.define_task(:environment)
    end

    let(:expected_base_paths) do
      [
        { from: '/alpha-taxonomy/a', to: '/alpha-taxonomy/b' },
        { from: '/alpha-taxonomy/c', to: '/alpha-taxonomy/d' },
      ]
    end

    it 'should receive an array of hashes' do
      ENV['TAXON_RENAMES'] = '/alpha-taxonomy/a,/alpha-taxonomy/b|/alpha-taxonomy/c,/alpha-taxonomy/d'

      taxon_renamer_double = double run!: true

      expect(AlphaTaxonomy::TaxonRenamer).to receive(:new)
        .with(base_paths: expected_base_paths)
        .and_return(taxon_renamer_double)

      Rake::Task["taxonomy:rename_base_paths"].invoke
    end
  end
end
