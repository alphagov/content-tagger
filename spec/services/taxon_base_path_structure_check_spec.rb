require "rails_helper"
require 'gds_api/test_helpers/content_store'

RSpec.describe TaxonBasePathStructureCheck, '#validate' do
  include ::GdsApi::TestHelpers::ContentStore

  it 'outputs check as all-valid' do
    content_store_has_valid_two_level_tree

    checker = TaxonBasePathStructureCheck.new(
      level_one_taxons: [{ 'base_path' => '/level-one' }]
    )
    checker.validate

    expect(checker.invalid_taxons).to be_empty
    expect(checker.path_validation_output).to all(start_with('✅'))
  end

  it 'records invalid taxons that do not have the same level one prefix' do
    content_store_has_tree_with_invalid_level_one_prefix

    checker = TaxonBasePathStructureCheck.new(
      level_one_taxons: [{ 'base_path' => '/level-one' }]
    )
    checker.validate

    expect(checker.invalid_taxons.size).to eq(1)
    expect(checker.invalid_taxons.last.base_path)
      .to eq("/some-other-path/level-two")
  end

  it 'records invalid taxons that do not follow the base path structure' do
    content_store_has_tree_with_long_base_path_structure

    checker = TaxonBasePathStructureCheck.new(
      level_one_taxons: [{ 'base_path' => '/level-one' }]
    )
    checker.validate

    expect(checker.invalid_taxons.size).to eq(1)
    expect(checker.invalid_taxons.last.base_path)
      .to eq("/imported-topic/topic/level-one/level-two")
  end

  it 'validates the whole tree even if the level one base path structure is incorrect' do
    content_store_has_tree_with_invalid_level_one_base_path

    checker = TaxonBasePathStructureCheck.new(
      level_one_taxons: [{ 'base_path' => '/level-one/taxon' }]
    )
    checker.validate

    expect(checker.invalid_taxons.size).to eq(1)
    expect(checker.invalid_taxons.last.base_path).to eq("/level-one/taxon")
    expect(checker.path_validation_output).to eq(
      [
        "❌ /level-one/taxon",
        "✅    ├── /level-one/level-two"
      ]
    )
  end

  # /level-one
  #   /level-one/level-two
  def content_store_has_valid_two_level_tree
    content_store_has_item(
      '/level-one',
      {
        "base_path" => "/level-one",
        "content_id" => "CONTENT-ID-LEVEL-ONE",
        "title" => "Level One",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/level-one/level-two",
              "content_id" => "CONTENT-ID-LEVEL-TWO",
              "title" => "Level Two",
              "links" => {}
            }
          ]
        }
      }.to_json, draft: true
    )

    content_store_has_item(
      '/level-one/level-two',
      {
        "base_path" => "/level-one/level-two",
        "content_id" => "CONTENT-ID-LEVEL-TWO",
        "title" => "Level Two",
        "links" => {}
      }.to_json, draft: true
    )
  end

  # /level-one
  #   /some-other-path/level-two
  def content_store_has_tree_with_invalid_level_one_prefix
    content_store_has_item(
      '/level-one',
      {
        "base_path" => "/level-one",
        "content_id" => "CONTENT-ID-LEVEL-ONE",
        "title" => "Level One",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/some-other-path/level-two",
              "content_id" => "CONTENT-ID-LEVEL-TWO",
              "title" => "Level Two",
              "links" => {}
            }
          ]
        }
      }.to_json, draft: true
    )

    content_store_has_item(
      '/some-other-path/level-two',
      {
        "base_path" => "/some-other-path/level-two",
        "content_id" => "CONTENT-ID-LEVEL-TWO",
        "title" => "Level Two",
        "links" => {}
      }.to_json, draft: true
    )
  end

  # /level-one
  #   /imported-topic/topic/level-one/level-two
  def content_store_has_tree_with_long_base_path_structure
    content_store_has_item(
      '/level-one',
      {
        "base_path" => "/level-one",
        "content_id" => "CONTENT-ID-LEVEL-ONE",
        "title" => "Level One",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/imported-topic/topic/level-one/level-two",
              "content_id" => "CONTENT-ID-LEVEL-TWO",
              "title" => "Level Two",
              "links" => {}
            }
          ]
        }
      }.to_json, draft: true
    )

    content_store_has_item(
      '/imported-topic/topic/level-one/level-two',
      {
        "base_path" => "/imported-topic/topic/level-one/level-two",
        "content_id" => "CONTENT-ID-LEVEL-TWO",
        "title" => "Level Two",
        "links" => {}
      }.to_json, draft: true
    )
  end

  # /level-one/taxon
  #   /level-one/level-two
  def content_store_has_tree_with_invalid_level_one_base_path
    content_store_has_item(
      '/level-one/taxon',
      {
        "base_path" => "/level-one/taxon",
        "content_id" => "CONTENT-ID-LEVEL-ONE",
        "title" => "Level One",
        "links" => {
          "child_taxons" => [
            {
              "base_path" => "/level-one/level-two",
              "content_id" => "CONTENT-ID-LEVEL-TWO",
              "title" => "Level Two",
              "links" => {}
            }
          ]
        }
      }.to_json, draft: true
    )

    content_store_has_item(
      '/level-one/level-two',
      {
        "base_path" => "/level-one/level-two",
        "content_id" => "CONTENT-ID-LEVEL-TWO",
        "title" => "Level Two",
        "links" => {}
      }.to_json, draft: true
    )
  end
end
