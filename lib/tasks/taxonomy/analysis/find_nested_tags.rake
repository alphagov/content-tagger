require 'set'
require 'csv'

namespace :taxonomy do
  namespace :analysis do
    desc "Find any content tagged at one taxon level, then tagged again at one of those taxon's ancestors"
    task :find_nested_tags, [:root_taxon_id] => [:environment] do |_, args|
      root_taxon_id = args.fetch(:root_taxon_id)
      root_taxon = OpenStruct.new Services.publishing_api.get_content(root_taxon_id).to_h
      taxonomy = Taxonomy::ExpandedTaxonomy.new(root_taxon.content_id)
      taxonomy.build

      nested_tag_warnings = find_content_tagged_at_multiple_levels(taxonomy.child_expansion)

      output = format_warnings_as_rows(nested_tag_warnings)

      output.each do |row|
        puts row.to_csv
      end
    end

    def find_content_tagged_at_multiple_levels(taxon, content_already_tagged = {})
      taxon_base_path = taxon.base_path

      taxon_content = Services.publishing_api.get_linked_items(
        taxon.content_id,
        link_type: "taxons",
        fields: %w[base_path content_id title]
      ).to_a

      nested_tag_warnings = []

      taxon_content.each do |content|
        content_base_path = content['base_path']
        already_tagged = false

        if content_already_tagged.key?(content_base_path)
          already_tagged = true
        else
          # Use a hash rather than a set, since sets do not guarantee ordering, but hash keys enumerate in insertion
          # order, which will preserve a notion of taxonomy hierarchy
          content_already_tagged[content_base_path] = {}
        end

        content_already_tagged[content_base_path][taxon_base_path] = ''

        next unless already_tagged

        content_links = Services.publishing_api.get_expanded_links(content['content_id']).to_h
        organisations = content_links.dig('expanded_links', 'organisations') || []
        organisation_titles = organisations.map { |organisation| organisation['title'] }

        nested_tag_warnings << {
          organisation: organisation_titles.join('; '),
          content_base_path: content_base_path,
          content_title: content['title'],
          content_id: content['content_id'],
          tagged_taxons: content_already_tagged[content_base_path],
        }
      end

      child_taxons = taxon.children

      if child_taxons
        child_taxons.each do |child_taxon|
          nested_tag_warnings += find_content_tagged_at_multiple_levels(child_taxon, clone_hash_of_hashes(content_already_tagged))
        end
      end

      nested_tag_warnings
    end

    def clone_hash_of_hashes(hash_of_hashes)
      hash_of_hashes.each_with_object({}) do |(key, hash), clone|
        clone[key] = hash.clone
      end
    end

    def format_warnings_as_rows(warnings)
      warnings_by_content_id = warnings.each_with_object(Hash.new { |h, k| h[k] = [] }) do |warning, grouped_warnings|
        grouped_warnings[warning[:content_id]] << warning
      end

      warnings_by_content_id.each_with_object([]) do |(_, content_warnings), rows|
        nested_tags = content_warnings.map { |warning| warning[:tagged_taxons] }
        unique_nested_tags = remove_subset_hashes_from nested_tags

        unique_nested_tags.each do |tags|
          row = [
            content_warnings.first[:organisation],
            content_warnings.first[:content_id],
            content_warnings.first[:content_base_path],
            content_warnings.first[:content_title],
          ]

          rows << row + tags.keys
        end
      end
    end

    # Given an array of hashes, this will remove any hashes that are proper subsets of the others (ie this will NOT
    # remove duplicate hashes)
    def remove_subset_hashes_from(list_of_hashes)
      list_of_hashes.each_with_object([]) do |hash, list_without_subsets|
        is_subset = false
        list_of_hashes.each do |other_hash|
          if hash < other_hash
            is_subset = true
            break
          end
        end
        list_without_subsets << hash unless is_subset
      end
    end
  end
end
