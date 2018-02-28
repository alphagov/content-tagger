require 'rails_helper'
require 'gds_api/test_helpers/content_store'

RSpec.describe 'taxonomy:validate_taxons_base_paths' do
  include ::GdsApi::TestHelpers::ContentStore
  include RakeTaskHelper

  it 'outputs check as all-valid' do
    content_store_has_valid_two_level_tree

    expect {
      rake 'taxonomy:validate_taxons_base_paths'
    }.to output(<<~LOG).to_stdout_from_any_process
      ✅ /level-one
      ✅    ├── /level-one/level-two
    LOG
  end

  it 'records invalid taxons that do not have the same level one prefix' do
    content_store_has_tree_with_invalid_level_one_prefix

    expect {
      rake 'taxonomy:validate_taxons_base_paths'
    }.to output(<<~LOG).to_stdout_from_any_process
      ✅ /level-one
      ❌    ├── /some-other-path/level-two
      ------------------------------------
      The following taxons do not follow the taxon URL structure:
      CONTENT-ID-LEVEL-TWO /some-other-path/level-two
    LOG
  end

  it 'records invalid taxons that do not follow the base path structure' do
    content_store_has_tree_with_long_base_path_structure

    expect {
      rake 'taxonomy:validate_taxons_base_paths'
    }.to output(<<~LOG).to_stdout_from_any_process
      ✅ /level-one
      ❌    ├── /imported-topic/topic/level-one/level-two
      ------------------------------------
      The following taxons do not follow the taxon URL structure:
      CONTENT-ID-LEVEL-TWO /imported-topic/topic/level-one/level-two
    LOG
  end

  it 'validates the whole tree even if the level one base path structure is incorrect' do
    content_store_has_tree_with_invalid_level_one_base_path

    expect {
      rake 'taxonomy:validate_taxons_base_paths'
    }.to output(<<~LOG).to_stdout_from_any_process
      ❌ /level-one/taxon
      ✅    ├── /level-one/level-two
      ------------------------------------
      The following taxons do not follow the taxon URL structure:
      CONTENT-ID-LEVEL-ONE /level-one/taxon
    LOG
  end

  # /level-one
  #   /level-one/level-two
  def content_store_has_valid_two_level_tree
    content_store_has_item(
      '/',
      {
        "base_path" => "/",
        "content_id" => "CONTENT-ID-ROOT",
        "title" => "Root",
        "links" => {
          "level_one_taxons" => [
            {
              "base_path" => "/level-one",
              "content_id" => "CONTENT-ID-LEVEL-ONE",
              "title" => "Level One"
            }
          ]
        }
      }.to_json, draft: true
    )

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
      '/',
      {
        "base_path" => "/",
        "content_id" => "CONTENT-ID-ROOT",
        "title" => "Root",
        "links" => {
          "level_one_taxons" => [
            {
              "base_path" => "/level-one",
              "content_id" => "CONTENT-ID-LEVEL-ONE",
              "title" => "Level One"
            }
          ]
        }
      }.to_json, draft: true
    )

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
      '/',
      {
        "base_path" => "/",
        "content_id" => "CONTENT-ID-ROOT",
        "title" => "Root",
        "links" => {
          "level_one_taxons" => [
            {
              "base_path" => "/level-one",
              "content_id" => "CONTENT-ID-LEVEL-ONE",
              "title" => "Level One"
            }
          ]
        }
      }.to_json, draft: true
    )

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
      '/',
      {
        "base_path" => "/",
        "content_id" => "CONTENT-ID-ROOT",
        "title" => "Root",
        "links" => {
          "level_one_taxons" => [
            {
              "base_path" => "/level-one/taxon",
              "content_id" => "CONTENT-ID-LEVEL-ONE",
              "title" => "Level One"
            }
          ]
        }
      }.to_json, draft: true
    )

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
