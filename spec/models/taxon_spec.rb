require 'rails_helper'

RSpec.describe Taxon do
  context 'validations' do
    it 'is not valid without a title' do
      taxon = described_class.new
      expect(taxon).to_not be_valid
      expect(taxon.errors.keys).to include(:title)
    end
  end

  it 'generates unique base paths for the same title' do
    taxon_1 = described_class.new(title: 'A Title')
    taxon_2 = described_class.new(title: 'A Title')

    expect(taxon_1.base_path).to_not eq(taxon_2.base_path)
  end

  context 'without notes_for_editors set' do
    it 'returns an empty string to comply with the schema definition' do
      taxon = described_class.new

      expect(taxon.notes_for_editors).to eq('')
    end
  end
end
