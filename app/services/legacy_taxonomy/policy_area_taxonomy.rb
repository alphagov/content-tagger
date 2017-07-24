module LegacyTaxonomy
  class PolicyAreaTaxonomy
    attr_accessor :path_prefix, :root_content_id

    BASE_PATH = '/government/topics'.freeze
    TITLE = 'Policy Areas'.freeze

    def initialize(path_prefix)
      @path_prefix = path_prefix
      @root_content_id = Client::PublishingApi.content_id_for_base_path(BASE_PATH)
    end

    def to_taxonomy_branch
      @taxon = TaxonData.new(
        title: TITLE,
        description: TITLE + ' Taxonomy',
        legacy_content_id: root_content_id,
        path_slug: BASE_PATH,
        path_prefix: path_prefix,
        child_taxons: child_taxons
      )
    end

    def child_taxons
      first_level_taxons
    end

    def first_level_taxons
      policy_areas = Client::SearchApi.policy_areas
      policy_areas.map do |policy_area|
        TaxonData.new(
          title: policy_area['title'],
          description: policy_area['description'],
          path_slug: policy_area['link'],
          path_prefix: path_prefix,
          legacy_content_id: Client::PublishingApi.content_id_for_base_path(policy_area['link']),
          tagged_pages: Client::SearchApi.content_tagged_to_policy_area(policy_area['slug'])
        )
      end
    end
  end
end
