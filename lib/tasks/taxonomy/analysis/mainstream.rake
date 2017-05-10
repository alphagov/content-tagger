require 'csv'
require 'set'

namespace :taxonomy do
  namespace :analysis do
    desc 'Determine how much mainstream content is tagged at and below each taxon'
    task :mainstream_analysis, [:root_taxon_id] => [:environment] do |_, args|
      root_taxon_id = args.fetch(:root_taxon_id)
      root_taxon = OpenStruct.new Services.publishing_api.get_content(root_taxon_id).to_h
      taxonomy = Taxonomy::ExpandedTaxonomy.new(root_taxon.content_id)
      taxonomy.build

      results = find_mainstream_count_and_max_depth(taxonomy.child_expansion)

      puts [
        'base path',
        'page type',
        'mainstream at this level',
        'mainstream below',
        'total mainstream',
        'content at this level',
        'content below',
        'total content',
      ].to_csv

      results.each_pair do |base_path, result|
        puts [
          base_path,
          result[:navigation_page_type],
          result[:mainstream_at_this_level],
          result[:mainstream_below],
          result[:mainstream_total],
          result[:guidance_at_this_level],
          result[:guidance_below],
          result[:guidance_total],
        ].to_csv
      end
    end

    def find_mainstream_count_and_max_depth(taxon)
      content_items = content_tagged_to(taxon)
      mainstream_count_at_this_taxon = number_of_mainstream_items_in(content_items)
      guidance_count_at_this_taxon = number_of_guidance_items_in(content_items)
      depth_below_this_taxon = 0
      mainstream_count_below_this_taxon = 0
      guidance_count_below_this_taxon = 0
      results = {}

      taxon.children.each do |child_taxon|
        results.merge!(find_mainstream_count_and_max_depth(child_taxon))
        base_path = child_taxon.base_path
        child_depth = results[base_path][:depth] + 1
        child_mainstream_count = results[base_path][:mainstream_total]
        child_guidance_count = results[base_path][:guidance_total]

        depth_below_this_taxon = [depth_below_this_taxon, child_depth].max
        mainstream_count_below_this_taxon += child_mainstream_count
        guidance_count_below_this_taxon += child_guidance_count
      end

      base_path = taxon.base_path
      results[base_path] = {
        depth: depth_below_this_taxon,
        navigation_page_type: page_type_from_depth(depth_below_this_taxon),
        mainstream_at_this_level: mainstream_count_at_this_taxon,
        mainstream_below: mainstream_count_below_this_taxon,
        mainstream_total: mainstream_count_at_this_taxon + mainstream_count_below_this_taxon,
        guidance_at_this_level: guidance_count_at_this_taxon,
        guidance_below: guidance_count_below_this_taxon,
        guidance_total: guidance_count_at_this_taxon + guidance_count_below_this_taxon,
      }

      results
    end

    def number_of_mainstream_items_in(content_items)
      content_items.count do |content_item|
        mainstream_document_types.include? content_item['document_type']
      end
    end

    def number_of_guidance_items_in(content_items)
      content_items.count do |content_item|
        supertypes = GovukDocumentTypes.supertypes(document_type: content_item['document_type'])
        supertypes['navigation_document_supertype'] == 'guidance'
      end
    end

    def content_tagged_to(taxon)
      Services.publishing_api.get_linked_items(
        taxon.content_id,
        link_type: "taxons",
        fields: %w(base_path content_id title document_type)
      ).to_a
    end

    def page_type_from_depth(depth)
      case depth
      when 0
        'leaf'
      when 1
        'accordion'
      else
        'grid'
      end
    end

    def mainstream_document_types
      %w(
        answer
        calculator
        calendar
        guide
        local_transaction
        place
        programme
        simple_smart_answer
        smart_answer
        transaction
      ).to_set.freeze
    end
  end
end
