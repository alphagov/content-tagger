require "facet_group_importer"
require "facet_data_tagger"

namespace :facets do
  desc <<-DESC
    Imports a facet group defined in a YAML file located at `facet_group_file_path`.
    This creates the relevant facet_group, facets and facet_values content items
    as drafts in the Publishing API. It also links these content items to reflect the
    shallow tree structure of a facet group.
  DESC
  task :import_facet_group, [:facet_group_file_path] => :environment do |_, args|
    FacetGroupImporter.new(args[:facet_group_file_path]).import
  end

  desc <<-DESC
    Publishes a facet group defined in a YAML file located at `facet_group_file_path`.
    This publishes a draft facet group created by the `import_facet_group` task.
  DESC
  task :publish_facet_group, [:facet_group_file_path] => :environment do |_, args|
    FacetGroupImporter.new(args[:facet_group_file_path]).publish
  end

  desc <<-DESC
    Links the content items at the base paths in the tagging CSV file to the facet values
    matching the facet group definitions. This effectively tags content to facets.
  DESC
  task :tag_content_to_facet_values, %i[tagging_file_path facet_group_file_path] => :environment do |_, args|
    FacetDataTagger.new(args[:tagging_file_path], args[:facet_group_file_path]).link_content_to_facet_values
  end

  desc <<-DESC
    Sends a patch links request for all content tagged to a facet_group.
  DESC
  task :patch_links_to_facet_group, [:facet_group_content_id] => :environment do |_, args|
    facet_group_content_id = args[:facet_group_content_id]

    content_items_enum = Services.rummager.search_enum(
      filter_facet_groups: facet_group_content_id
    )

    content_ids = Services.publishing_api.lookup_content_ids(base_paths: content_items_enum.pluck("link"))

    content_ids.each do |_, content_id|
      Services.publishing_api.patch_links(content_id, links: { finder: [Facets::FinderService::LINKED_FINDER_CONTENT_ID] })
    end
  end
end
