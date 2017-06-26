require 'rails_helper'

RSpec.describe RootTaxonsForm do
  include PublishingApiHelper
  include ContentItemHelper

  describe '#taxons_for_select' do
    before :each do
      publishing_api_has_links("content_id" => RootTaxonsForm::HOMEPAGE_CONTENT_ID,
                               "links" => { "root_taxons" => [""] })
    end
    it 'returns all taxons for the select box' do
      @linkable_taxon_hash = FactoryGirl.build_list(:linkable_taxon_hash, 2)

      publishing_api_has_linkables(
        @linkable_taxon_hash,
        document_type: 'taxon'
      )

      taxons_for_select = RootTaxonsForm.new.taxons_for_select

      expect(taxons_for_select).to eq(@linkable_taxon_hash.map { |l| [l[:internal_name], l[:content_id]] })
    end
  end

  describe '#update' do
    before :each do
      stub_any_publishing_api_patch_links
    end
    it 'updates given taxons, ignoring empty strings' do
      RootTaxonsForm.new(root_taxons: ["", "ID-3", "ID-4"]).update
      assert_publishing_api_patch_links(RootTaxonsForm::HOMEPAGE_CONTENT_ID, "links" =>
        { "root_taxons" => ["ID-3", "ID-4"] })
    end
    it 'removes all taxons' do
      RootTaxonsForm.new(root_taxons: [""]).update
      assert_publishing_api_patch_links(RootTaxonsForm::HOMEPAGE_CONTENT_ID, "links" =>
        { "root_taxons" => [] })
    end
  end
end
