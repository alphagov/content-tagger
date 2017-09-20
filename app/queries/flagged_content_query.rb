class FlaggedContentQuery
  attr_reader :params

  def initialize(params)
    @params = params.slice(:taxonomy_branch, :flagged)
  end

  def each(&block)
    items.each(&block)
  end

  def items
    ProjectContentItem
      .for_taxonomy_branch(params[:taxonomy_branch])
      .flagged_with(params[:flagged])
      .order(updated_at: :desc)
  end
end
