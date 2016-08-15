class TaggingSpreadsheetsController < ApplicationController
  def index
    render :index, locals: { tagging_spreadsheets: presented_tagging_spreadsheets }
  end

  def new
    @tagging_spreadsheet = TaggingSpreadsheet.new
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
      @tagging_spreadsheet = tagging_spreadsheet
      render :new
    end
  end

  def show
    @tagging_spreadsheet = TaggingSpreadsheet.find(params[:id])
    @tag_mappings = @tagging_spreadsheet.tag_mappings.by_content_base_path.by_link_title
  end

  def import_progress
    tagging_spreadsheet = TaggingSpreadsheet.find(params[:tagging_spreadsheet_id])
    tag_mappings = tagging_spreadsheet.tag_mappings.by_content_base_path.by_link_title
    render partial: "import_progress_bar", formats: :html, locals: { tag_mappings: tag_mappings }
  end

  def refetch
    tagging_spreadsheet = TaggingSpreadsheet.find(params.fetch(:tagging_spreadsheet_id))
    tagging_spreadsheet.tag_mappings.delete_all
    tagging_spreadsheet.update_attributes!(state: "uploaded")
    InitialTaggingImport.perform_async(tagging_spreadsheet.id)
    redirect_to tagging_spreadsheet, success: I18n.t('tag_import.import_refetched')
  end

  def publish_tags
    tagging_spreadsheet = TaggingSpreadsheet.find(params.fetch(:tagging_spreadsheet_id))
    TagImporter::PublishTags.new(tagging_spreadsheet, user: current_user).run
    redirect_to tagging_spreadsheet, success: I18n.t('tag_import.import_started')
  end

  def destroy
    tagging_spreadsheet = TaggingSpreadsheet.find(params[:id])
    tagging_spreadsheet.mark_as_deleted
    redirect_to tagging_spreadsheets_path, success: I18n.t('tag_import.import_removed')
  end

private

  def tagging_spreadsheets
    TaggingSpreadsheet.active.newest_first.includes(:added_by)
  end

  def presented_tagging_spreadsheets
    tagging_spreadsheets.map do |tagging_spreadsheet|
      TaggingSpreadsheetPresenter.new(tagging_spreadsheet)
    end
  end

  def tagging_spreadsheet_params
    params.require(:tagging_spreadsheet).permit(:url, :description)
  end
end
