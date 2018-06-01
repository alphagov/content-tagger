require 'rails_helper'
require 'taxon_description_updater'

RSpec.describe TaxonDescriptionUpdater do
  let(:with_dots) do
    [
      create_taxon('content_id' => 'desc-...', 'title' => 'title ...', 'description' => '...', 'phase' => 'live'),
      create_taxon('content_id' => 'desc-other', 'title' => 'title other', 'description' => 'other...'),
    ]
  end
  let(:with_tbc) do
    [
      create_taxon('content_id' => 'desc-tbc', 'title' => 'title2 ...', 'description' => 'tbc', 'phase' => 'beta'),
      create_taxon('content_id' => 'desc-other-tbc', 'title' => 'title2 other', 'description' => 'other tbc'),
    ]
  end

  before do
    publishing_api_has_content(with_dots, per_page: 5000, q: '...', search_in: ['description'])
    publishing_api_has_content(with_tbc, per_page: 5000, q: 'tbc', search_in: ['description'])
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish

    TaxonDescriptionUpdater.new(%w[... tbc]).call
  end

  it 'updated the ... records correctly' do
    assert_put_content('desc-...', content_id: 'desc-...', title: 'title ...', phase: 'live')
    assert_publish 'desc-...'
    assert_no_put_content('desc-other')
    assert_no_publish('desc-other')
  end

  it 'updated the tbc records correctly' do
    assert_put_content('desc-tbc', content_id: 'desc-tbc', title: 'title2 ...', phase: 'beta')
    assert_publish 'desc-tbc'
    assert_no_put_content('desc-other-tbc')
    assert_no_publish('desc-other-tbc')
  end

private

  def create_taxon(attributes)
    attributes.merge(
      'schema_name' => 'taxon',
      'content_store' => 'live',
      'user_facing_version' => 4,
      'publication_state' => 'published',
      'lock_version' => 3,
      'updated_at' => Time.now,
      'state_history' => []
    )
  end

  def assert_put_content(content_id, params)
    param_defaults = {
      description: nil,
      schema_name: 'taxon',
      update_type: 'minor'
    }
    assert_publishing_api_put_content(content_id, param_defaults.merge(params), 1)
  end

  def assert_no_put_content(content_id)
    assert_publishing_api_put_content(content_id, nil, 0)
  end

  def assert_publish(content_id)
    assert_publishing_api_publish content_id
  end

  def assert_no_publish(content_id)
    assert_publishing_api_publish content_id, nil, 0
  end
end
