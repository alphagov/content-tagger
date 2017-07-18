module LegacyTaxonomy
  class MainstreamBrowseTaxonomy
    attr_accessor :path_prefix

    BASE_PATH = '/browse'.freeze

    def initialize(path_prefix)
      @path_prefix = path_prefix
    end

    def to_taxonomy_branch
      root_content_id = Client::PublishingApi.content_id_for_base_path(BASE_PATH)
      @taxon = TaxonData.new(
        title: 'Browse',
        description: 'Mainstream Browse Taxonomy',
        browse_page_content_id: root_content_id,
        path_slug: BASE_PATH,
        path_prefix: path_prefix,
        child_taxons: child_taxons(root_content_id)
      )
    end

  private

    def child_taxons(root_content_id)
      first_level_taxons(root_content_id).each do |first_level_taxon|
        first_level_taxon.child_taxons =
          second_level_taxons(first_level_taxon).each do |second_level_taxon|
            second_level_taxon.child_taxons = third_level_taxons(second_level_taxon)
            second_level_taxon.tagged_pages -=
              second_level_taxon.child_taxons.map(&:tagged_pages).flatten
          end
      end
    end

    def first_level_taxons(root_content_id)
      Client::PublishingApi
        .get_expanded_links(root_content_id)
        .fetch("top_level_browse_pages", [])
        .map do |browse_page|
          TaxonData.new(
            title: browse_page['title'],
            description: browse_page['description'],
            browse_page_content_id: browse_page['content_id'],
            path_slug: browse_page['base_path'],
            path_prefix: path_prefix
          )
        end
    end

    def second_level_taxons(parent_taxon)
      Client::PublishingApi
        .get_expanded_links(parent_taxon.browse_page_content_id)
        .fetch('second_level_browse_pages', [])
        .map do |browse_page|
          base_path = browse_page['base_path']
          content_id = browse_page['content_id']
          TaxonData.new(
            title: browse_page['title'],
            description: browse_page['description'],
            browse_page_content_id: content_id,
            path_slug: base_path,
            path_prefix: path_prefix,
            tagged_pages: Client::SearchApi.content_ids_tagged_to_browse_page(content_id)
          )
        end
    end

    def third_level_taxons(parent_taxon)
      Client::PublishingApi.get_content_groups(parent_taxon.browse_page_content_id)
        .reject { |g| g['name'].empty? || g['contents'].empty? }
        .map do |group|
          path_slug = parent_taxon.path_slug + '/' + group['name'].parameterize
          TaxonData.new(
            title: group['name'],
            description: group['name'],
            path_slug: path_slug,
            path_prefix: path_prefix,
            tagged_pages: group['contents']
              .map { |content_base_path| Client::PublishingApi.content_id_for_base_path(content_base_path) }
              .compact
          )
        end
    end
  end
end
