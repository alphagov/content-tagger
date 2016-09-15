class TaggingSpreadsheetsController < ApplicationController
  def index
    render :index, locals: { tagging_spreadsheets: presented_tagging_spreadsheets }
  end

  def new
    render :new, locals: { tagging_spreadsheet: TaggingSpreadsheet.new }
  end

  def create
    tagging_spreadsheet = TaggingSpreadsheet.new(tagging_spreadsheet_params)
    tagging_spreadsheet.user_uid = current_user.uid
    tagging_spreadsheet.state = "uploaded"

    if tagging_spreadsheet.valid?
      tagging_spreadsheet.save!
      InitialTaggingImport.perform_async(tagging_spreadsheet.id)
      redirect_to tagging_spreadsheet, success: I18n.t('tag_import.import_created')
    else
      render :new, locals: { tagging_spreadsheet: tagging_spreadsheet }
    end
  end

  def show
    render :show, locals: {
      tagging_spreadsheet: tagging_spreadsheet,
      aggregated_tag_mappings: presented_aggregated_tag_mappings,
      confirmed: tag_mappings.completed.count,
      progress_path: tagging_spreadsheet_progress_path(tagging_spreadsheet),
    }
  end

  def progress
    render partial: "tag_update_progress_bar", formats: :html, locals: {
      tag_mappings: tag_mappings,
      confirmed: tag_mappings.completed.count,
      progress_path: tagging_spreadsheet_progress_path(tagging_spreadsheet),
    }
  end

  def refetch
    tagging_spreadsheet.tag_mappings.delete_all
    tagging_spreadsheet.update_attributes!(state: "uploaded")
    InitialTaggingImport.perform_async(tagging_spreadsheet.id)

    redirect_to tagging_spreadsheet, success: I18n.t('tag_import.import_refetched')
  end

  def publish_tags
    QueueLinksForPublishing.call(tagging_spreadsheet, user: current_user)

    redirect_to tagging_spreadsheet, success: I18n.t('tag_import.import_started')
  end

  def destroy
    tagging_spreadsheet.mark_as_deleted
    redirect_to tagging_spreadsheets_path, success: I18n.t('tag_import.import_removed')
  end

private

  def tagging_spreadsheet
    TaggingSpreadsheet.find(params[:id] || params.fetch(:tagging_spreadsheet_id))
  end

  def tag_mappings
    tagging_spreadsheet.tag_mappings
      .by_state
      .by_content_base_path
      .by_link_title
  end

  def aggregated_tag_mappings
    tagging_spreadsheet.aggregated_tag_mappings
  end

  def presented_aggregated_tag_mappings
    aggregated_tag_mappings.map do |aggregated_tag_mapping|
      AggregatedTagMappingPresenter.new(aggregated_tag_mapping)
    end
  end

  def tagging_spreadsheets
    TaggingSpreadsheet.active.newest_first.includes(:added_by)
  end

  def presented_tagging_spreadsheets
    tagging_spreadsheets.map do |tagging_spreadsheet|
      TaggingSpreadsheetPresenter.new(tagging_spreadsheet)
    end
  end

  def tagging_spreadsheet_params
    taggging_params = params.require(:tagging_spreadsheet).permit(:url, :description)
    taggging_params["url"] = taggging_params["url"].strip

    taggging_params
  end
end
