module Projects
  class BulkSearch
    TAGGED_STATE_TAGGED = 'tagged'.freeze
    TAGGED_STATE_NOT_TAGGED = 'not_tagged'.freeze
    TAGGED_STATE_ALL = 'all'.freeze

    TAGGED_STATES = [TAGGED_STATE_TAGGED, TAGGED_STATE_NOT_TAGGED, TAGGED_STATE_ALL].freeze

    attr_reader :project, :params

    def initialize(project, params)
      @project, @params = project, params
    end

    def project_content_items_to_display
      @_project_content_items_to_display = begin
        items = project.content_items.with_valid_ids

        tagged_state_filter = filter_params[:tagged_state]

        if tagged_state_filter && tagged_state_filter != TAGGED_STATE_ALL
          unless TAGGED_STATES.include? tagged_state_filter
            raise ActionController::BadRequest,
                  "The value \"#{tagged_state_filter}\" is an invalid tagging state."
          end

          items = items.where(done: tagged_state_filter == TAGGED_STATE_TAGGED)
        end

        query = filter_params[:query]
        items = items.matching_search(query) if query

        items
      end
    end

    def filter_params
      params.permit(:query, :tagged_state)
    end
  end
end
