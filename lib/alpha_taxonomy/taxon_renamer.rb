module AlphaTaxonomy
  class TaxonRenamer
    def initialize(logger: Logger.new(STDOUT), base_paths:)
      @log = logger
      @base_paths = base_paths
    end

    def run!
      @base_paths.each do |base_path|
        content_id = lookup_id_by_base_path(base_path)

        next unless content_id

        @log.info "-- Requesting base_path change to #{base_path[:to]}"

        send_to_publishing_api(
          content_id,
          AlphaTaxonomy::TaxonPresenter.new(title: normalised_title(base_path[:to])).present
        )
      end
    end

  private

    def normalised_title(base_path)
      base_path.split('/').last.tr('-', ' ').capitalize
    end

    def send_to_publishing_api(content_id, payload)
      Services.publishing_api.put_content(content_id, payload)
      Services.publishing_api.publish(content_id, 'major')
    end

    def lookup_id_by_base_path(base_path)
      @log.info "Requesting content_id to Publishing API for #{base_path[:from]}"
      content_id = Services.publishing_api.lookup_content_id(base_path: base_path[:from])

      @log.info "#{base_path[:from]} content_id was not found" unless content_id

      content_id
    end
  end
end
