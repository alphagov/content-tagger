module LegacyTaxonomy
  module Client
    class SearchApi
      class << self
        def content_ids_tagged_to_browse_page(taxon_content_id)
          tagged = client.search(
            fields: %w(content_id),
            filter_mainstream_browse_page_content_ids: [taxon_content_id],
            count: 1000
          )

          tagged["results"]
            .map { |result| result['content_id'] }
            .compact
        end

        def policy_areas
          areas = client.search(
            filter_format: 'topic',
            count: 1000
          )

          areas['results']
        end

        def content_ids_tagged_to_policy_area(policy_area_slug)
          results = []

          count = 1000
          query = proc do |start, slug|
            client
              .search(
                fields: %w(content_id),
                filter_policy_areas: [slug],
                count: count,
                start: start
              )
              .dig('results')
              .map { |result| result['content_id'] }
          end

          start = 0
          loop do
            begin
              content_ids = query.call(start, policy_area_slug)
            rescue GdsApi::TimedOutException
              puts 'Time out - waiting for 5s'
              puts "#{start}/#{policy_area_slug}"
              sleep(5)
              next
            end

            break if content_ids.empty?
            results += content_ids
            start += count
          end

          results
        end

        def client
          Services.search
        end
      end
    end
  end
end
