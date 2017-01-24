require 'rails_helper'

RSpec.describe EducationTaxonNamer do
  describe 'rename_taxon' do
    it "names the theme root" do
      education = Taxon.new(
        title: 'Education, training and skills',
        description: 'Education things',
        path_prefix: '/alpha-taxonomy',
        path_slug: '/some-existing-slug',
      )
      described_class.rename_taxon(education)

      expect(education.base_path).to eq("/education")
    end

    it "names a child taxon based on the title" do
      pupil_participation = Taxon.new(
        title: 'Pupil participation in school governance',
        description: 'Pupil participation in school governance',
        path_prefix: '/alpha-taxonomy',
        path_slug: '/some-existing-slug',
      )
      described_class.rename_taxon(pupil_participation)

      expect(pupil_participation.base_path).to eq("/education/pupil-participation-in-school-governance")
    end

    it "names key stage 1 and key stage 2 taxons with a prefix" do
      key_stage_1 = Taxon.new(
        title: 'Key stage 1',
        description: 'Key Stage 1',
        path_prefix: '/alpha-taxonomy',
        path_slug: '/key-stage-1-slug',
      )

      maths = Taxon.new(
        title: 'Maths',
        description: 'Maths in Key Stage 1',
        path_prefix: '/alpha-taxonomy',
        path_slug: '/some-existing-slug',
      )

      expect_any_instance_of(RemoteTaxons).to receive(:parents_for_taxon).and_return([key_stage_1])

      described_class.rename_taxon(maths)

      expect(maths.base_path).to eq("/education/key-stage-1-maths")
    end
  end
end
