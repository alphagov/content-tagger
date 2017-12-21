require 'rails_helper'

RSpec.describe Taxonomy::ParentUpdate do
  include PublishingApiHelper

  let(:content_id) { SecureRandom.uuid }
  let(:parent_id) { SecureRandom.uuid }
  let(:associated_id) { SecureRandom.uuid }

  before :each do
    publishing_api_has_item(content_id: content_id, title: 'content')
    stub_any_publishing_api_patch_links
  end
  it 'updates a taxon with a new non-root taxon' do
    ::Taxonomy::ParentUpdate.new.set_parent(content_id, parent_taxon_id: parent_id, associated_taxon_ids: [associated_id])
    assert_publishing_api_patch_links(content_id, links: { root_taxon: [], parent_taxons: [parent_id], associated_taxons: [associated_id] })
  end
  it 'updates a parent taxon with a root taxon' do
    ::Taxonomy::ParentUpdate.new.set_parent(content_id, parent_taxon_id: GovukTaxonomy::ROOT_CONTENT_ID, associated_taxon_ids: [associated_id])
    assert_publishing_api_patch_links(content_id, links: { parent_taxons: [], root_taxon: [GovukTaxonomy::ROOT_CONTENT_ID], associated_taxons: [associated_id] })
  end
end
