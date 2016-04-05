module AlphaTaxonomy
  class TaxonRenamer
    def initialize(logger: Logger.new(STDOUT), base_paths:)
      @log = logger
      @base_paths = base_paths
    end

    def run!
      paths_and_content_ids = lookup_content_ids_by_base_paths

      @base_paths.each do |base_path_pair|
        content_id = paths_and_content_ids[base_path_pair[:from]]
        title = normalised_title(base_path_pair[:to])

        @log.info "-- Requesting base_path change for #{base_path_pair[:from]}"
        send_to_publishing_api(
          content_id,
          AlphaTaxonomy::TaxonPresenter.new(title: title).present
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

    def lookup_content_ids_by_base_paths
      Services.publishing_api.lookup_content_ids(
        base_paths: extract_from_base_paths(@base_paths)
      )
    end

    def extract_from_base_paths(base_paths)
      base_paths.map do |base_path|
        base_path[:from]
      end
    end
  end
end
