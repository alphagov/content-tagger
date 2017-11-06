require 'rails_helper'

RSpec.describe Taxon do
  before do
    create(:theme, :education)
  end

  context 'validations' do
    it 'is not valid without a title' do
      taxon = described_class.new
      expect(taxon).to_not be_valid
      expect(taxon.errors.keys).to include(:title)
    end

    it 'is not valid without a description' do
      taxon = described_class.new
      expect(taxon).to_not be_valid
      expect(taxon.errors.keys).to include(:description)
    end

    it 'is not valid without a path slug' do
      taxon = described_class.new(path_slug: '')

      expect(taxon).to_not be_valid
      expect(taxon.errors.keys).to include(:path_slug)
      expect(taxon.errors[:path_slug]).to include("alphanumeric path must begin with /")
    end
  end

  context 'when internal_name is not set' do
    it 'uses the title value' do
      taxon = described_class.new(title: 'I Title')

      expect(taxon.internal_name).to eql(taxon.title)
    end
  end

  context 'without notes_for_editors set' do
    it 'returns an empty string to comply with the schema definition' do
      taxon = described_class.new

      expect(taxon.notes_for_editors).to eq('')
    end
  end

  it 'must have a slug with alphanumeric characters and dashes only' do
    valid_taxon = described_class.new(
      title: 'Title',
      description: 'Description',
      path_prefix: "/education",
      path_slug: '/ab01-cd02',
    )

    expect(valid_taxon).to be_valid

    invalid_taxon = described_class.new(
      title: 'Title',
      description: 'Description',
      path_prefix: "/education",
      path_slug: '/slug/',
    )

    expect(invalid_taxon).to_not be_valid
    expect(invalid_taxon.errors.keys).to include(:path_slug)
  end

  describe '#base_path=' do
    it 'separates the prefix and slug values' do
      taxon = described_class.new(
        base_path: '/childcare-parenting/childcare-and-early-years'
      )

      expect(taxon.path_prefix).to eq '/childcare-parenting'
      expect(taxon.path_slug).to eq '/childcare-and-early-years'
    end
  end

  describe '#theme' do
    it "returns the theme" do
      taxon = Taxon.new(base_path: "/education/foo")

      expect(taxon.theme).to eql("Education")
    end
  end

  describe '#visible_to_departmental_editors' do
    it "defaults to false if it's not set" do
      taxon = Taxon.new
      expect(taxon.visible_to_departmental_editors).to be false
    end

    it "can be set through the initializer by value" do
      taxon = Taxon.new(visible_to_departmental_editors: true)
      expect(taxon.visible_to_departmental_editors).to be true
    end

    it "can be set through the initializer by string" do
      taxon = Taxon.new(visible_to_departmental_editors: "true")
      expect(taxon.visible_to_departmental_editors).to be true
    end
  end
end
