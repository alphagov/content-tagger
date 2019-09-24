class ProjectFilterQuery
  FILTER_TODO = "to do".freeze
  FILTER_FLAGGED = "flagged".freeze
  FILTER_DONE = "done".freeze
  FILTERS = [FILTER_TODO, FILTER_FLAGGED, FILTER_DONE].freeze

  attr_reader :params

  def initialize(params, project)
    @params = params.slice(:title_search, :filter)
    @project = project
  end

  def current_filter
    params[:filter] || FILTER_TODO
  end

  def items
    items = @project
      .content_items
      .with_valid_ids
      .order(updated_at: :desc)

    if params[:title_search].present?
      items = items.matching_search(params[:title_search])
    end

    case current_filter
    when FILTER_TODO
      items = items
                .todo
                .reorder(id: :asc) # Retain the spreadsheet order
    when FILTER_FLAGGED
      items = items.flagged
    when FILTER_DONE
      items = items.done
    end

    items
  end
end
