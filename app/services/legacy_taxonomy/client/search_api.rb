require 'gds_api/rummager'

module LegacyTaxonomy
  module Client
    class SearchApi
      class << self
        def content_tagged_to_browse_page(taxon_content_id)
          content_from_rummager(
            filter_mainstream_browse_page_content_ids: [taxon_content_id]
          )
        end

        def content_tagged_to_topic(topic_slug)
          content_from_rummager(
            filter_specialist_sectors: [remove_leading_slash(topic_slug)]
          )
        end

        def content_tagged_to_policy_area(policy_area_slug)
          content_from_rummager(filter_policy_areas: [policy_area_slug])
        end

        def content_tagged_to_policy(policy_slug)
          content_from_rummager(filter_policies: policy_slug)
        end

        def policy_areas
          areas = client.search(
            filter_format: 'topic',
            count: 1000
          )

          areas['results']
        end

        def content_from_rummager(query_params = {})
          results = []
          count = 1000
          start = 0
          fields = %w(content_id link)

          query = proc do |start_from, content_count|
            client
              .search(
                query_params.merge(
                  fields: fields,
                  start: start_from,
                  count: content_count
                )
              )
              .dig('results')
              .map { |result| result.slice(*fields) }
              .delete_if { |hsh| hsh.any? { |_, v| v.empty? } }
              .delete_if { |hsh| hsh.keys.sort != fields.sort }
          end

          loop do
            things = query.call(start, count)
            results += things
            start += count
            break if things.size.between?(0, count - 1)
          end

          results
        end

        def client
          @search ||= GdsApi::Rummager.new(
            Plek.new.find('rummager'),
            timeout: 20
          )
        end

        def remove_leading_slash(base_path)
          base_path.gsub(%r{^\/}, '')
        end
      end
    end
  end
end
