module LegacyTaxonomy
  class ThreeLevelTaxonomy
    attr_accessor :path_prefix

    def initialize(path_prefix, base_path:, title:, first_level_key:, second_level_key:)
      @path_prefix = path_prefix
      @base_path = base_path
      @title = title
      @first_level_key = first_level_key
      @second_level_key = second_level_key
    end

    def to_taxonomy_branch
      root_content_id = Client::PublishingApi.content_id_for_base_path(@base_path)

      TaxonData.new(
        title: @title,
        description: '',
        legacy_content_id: root_content_id,
        path_slug: @base_path,
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
        .fetch(@first_level_key, [])
        .map do |browse_page|
          TaxonData.new(
            title: browse_page['title'],
            description: browse_page['description'],
            legacy_content_id: browse_page['content_id'],
            path_slug: browse_page['base_path'],
            path_prefix: path_prefix
          )
        end
    end

    def second_level_taxons(parent_taxon)
      Client::PublishingApi
        .get_expanded_links(parent_taxon.legacy_content_id)
        .fetch(@second_level_key, [])
        .map do |browse_page|
          base_path = browse_page['base_path']
          content_id = browse_page['content_id']
          TaxonData.new(
            title: browse_page['title'],
            description: browse_page['description'],
            legacy_content_id: content_id,
            path_slug: base_path,
            path_prefix: path_prefix,
            tagged_pages: second_level_tagged_pages(content_id, base_path)
          )
        end
    end

    def third_level_taxons(parent_taxon)
      Client::PublishingApi.get_content_groups(parent_taxon.legacy_content_id)
        .reject { |g| g['name'].empty? || g['contents'].empty? }
        .map do |group|
          path_slug = parent_taxon.path_slug + '/' + group['name'].parameterize
          TaxonData.new(
            title: group['name'],
            description: group['name'],
            path_slug: path_slug,
            path_prefix: path_prefix,
            tagged_pages: third_level_tagged_pages(group['contents'])

          )
        end
    end

    def third_level_tagged_pages(group_contents)
      group_contents.each_with_object([]) do |content_base_path, memo|
        content_id = Client::PublishingApi.content_id_for_base_path(content_base_path)
        next unless content_id
        memo << {
          'link' => content_base_path,
          'content_id' => content_id
        }
      end
    end

    def second_level_tagged_pages(content_id, base_path)
      (
        Client::SearchApi.content_tagged_to_browse_page(content_id) +
          linked_related_topics(content_id) +
          Client::SearchApi.content_tagged_to_topic(base_path)
      ).uniq
    end

    def linked_related_topics(content_id)
      Client::PublishingApi
        .get_expanded_links(content_id)
        .fetch('related_topics', [])
        .map do |topic|
          {
            'content_id' => topic['content_id'],
            'link' => topic['base_path']
          }
        end
    end
  end
end
