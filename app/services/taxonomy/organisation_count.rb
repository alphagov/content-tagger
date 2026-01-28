module Taxonomy
  class OrganisationCount
    def all_taggings_per_organisation
      level_one_taxons = taxonomy_query.level_one_taxons
      level_one_taxons.map do |level_one_taxon|
        { title: level_one_taxon["title"], sheet: taggings_per_organisation(level_one_taxon) }
      end
    end

  private

    def headers
      %w[organisation total taxon_base_path_1 taxon_count_1 taxon_base_path_2 taxon_count_2]
    end

    def taggings_per_organisation(level_one_taxon)
      taxons_in_branch = child_taxons(level_one_taxon)
      results_per_organisation = tagging_count_per_organisation(taxons_in_branch)
      results_per_organisation.each_with_object([headers]) do |(organisation, countings), sheet|
        total_count = countings.sum { |(count, _)| count }
        row = [organisation, total_count]
        countings.sort_by { |(count, _)| -count }.each_with_object(row) do |(count, base_path), result_row|
          result_row << base_path << count
        end
        sheet << row
      end
    end

    # {organisation -> [count, base_path]}
    def tagging_count_per_organisation(taxons)
      taxons.each_with_object(Hash.new { |h, k| h[k] = [] }) do |taxon, result|
        tagging_count_per_organisation_for_taxon(taxon).each do |organisation, count|
          result[organisation] << [count, taxon["base_path"]]
        end
      end
    end

    def tagging_count_per_organisation_for_taxon(taxon)
      search_api_result = Services.search_api.search(aggregate_primary_publishing_organisation: 100_000, count: 0, filter_taxons: [taxon["content_id"]])
      search_api_result
        .dig("aggregates", "primary_publishing_organisation", "options")
        .each_with_object({}) do |result, total|
          total[result.dig("value", "slug")] = result["documents"]
      end
    end

    def child_taxons(level_one_taxon)
      taxonomy_query.child_taxons(level_one_taxon["base_path"]) << level_one_taxon
    end

    def taxonomy_query
      @taxonomy_query ||= Taxonomy::TaxonomyQuery.new(%i[base_path content_id title])
    end
  end
end
