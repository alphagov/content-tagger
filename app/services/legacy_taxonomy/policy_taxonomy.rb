module LegacyTaxonomy
  class PolicyTaxonomy
    attr_reader :path_prefix

    TITLE = 'Imported Policy Areas + Policies'.freeze
    BASE_PATH = '/government/topics'.freeze
    ABBREVIATION = "P".freeze

    def initialize(path_prefix)
      @path_prefix = path_prefix
    end

    def to_taxonomy_branch
      @taxon = TaxonData.new(
        title: TITLE,
        internal_name: "#{TITLE} [#{ABBREVIATION}]",
        description: TITLE + ' Taxonomy',
        path_slug: BASE_PATH,
        path_prefix: path_prefix,
        child_taxons: policy_areas
      )
    end

    def policy_areas
      areas = Client::SearchApi.policy_areas
      areas.map do |policy_area|
        TaxonData.new(
          title: policy_area['title'],
          internal_name: "#{policy_area['title']} [#{ABBREVIATION}]",
          description: policy_area['description'],
          path_slug: policy_area['link'],
          path_prefix: path_prefix,
          legacy_content_id: Client::PublishingApi.content_id_for_base_path(policy_area['link']),
          child_taxons: policies_for_policy_area(policy_area['slug'])
        )
      end
    end

    def policies_for_policy_area(policy_area_slug)
      policies = Client::Whitehall.policies_for_policy_area(policy_area_slug)
      policies.map do |policy_id|
        policy_content_item = Client::PublishingApi.client.get_content(policy_id)
        policy_slug = policy_content_item.to_h["base_path"].split("/").last
        path_slug = "#{BASE_PATH}/#{policy_area_slug}/#{policy_slug}"
        TaxonData.new(
          title: policy_content_item['title'],
          internal_name: "#{policy_content_item['title']} [#{ABBREVIATION}]",
          description: policy_content_item['description'],
          path_slug: path_slug,
          path_prefix: path_prefix,
          legacy_content_id: policy_id,
          tagged_pages: Client::SearchApi.content_tagged_to_policy(policy_slug)
        )
      end
    end
  end
end
