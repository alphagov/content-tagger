class FlaggedContentQuery
  attr_reader :params

  def initialize(params)
    @params = params.slice(:taxonomy_branch, :flagged)
  end

  def each(&block)
    items.each(&block)
  end

  def items
    if params[:flagged] == "missing_topic"
      project_content_items_with_suggested_tags_only
    else
      project_content_items
    end
  end

private

  def project_content_items_with_suggested_tags_only
    project_content_items.select { |c| c.suggested_tags.present? }
  end

  def project_content_items
    ProjectContentItem
      .for_taxonomy_branch(params[:taxonomy_branch])
      .flagged_with(params[:flagged])
      .order(updated_at: :desc)
  end
end
