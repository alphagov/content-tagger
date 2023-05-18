class ProjectContentItemsController < ApplicationController
  before_action :ensure_user_can_access_tagathon_tools!

  def index
    render :index,
           locals: { project_content_items: FlaggedContentQuery.new(params),
                     title: index_page_title }
  end

  def update
    tag_content
    content_item.touch
    head :ok
  rescue GdsApi::HTTPClientError
    head :bad_request
  end

  def bulk_update
    tagger = Projects::BulkTagger.new(**bulk_params)
    tagger.commit
    render json: tagger.result
  end

  def flags
    locals = { project:, content_item: }

    respond_to do |format|
      format.js { render layout: false, locals: }
    end
  end

  def update_flags
    content_item.update!(flag_params)
    content_item.save!

    respond_to do |format|
      format.js { render layout: false, locals: { content_item: } }
    end
  end

  def mark_as_done
    content_item.done!
    respond_to do |format|
      format.js { head :ok }
      format.html { redirect_back fallback_location: project_path(project) }
    end
  end

private

  def index_page_title
    response = Services.publishing_api.get_content(params[:taxonomy_branch])
    taxonomy_title = response.to_h["title"]
    "Content flagged for #{taxonomy_title}"
  end

  def flag_params
    params.require(:project_content_item).permit(:flag, :suggested_tags, :need_help_comment)
  end

  def bulk_params
    params
      .require(:bulk_tagging)
      .permit(:taxons, content_items: [])
      .to_h
      .symbolize_keys
      .tap { |hsh| hsh[:taxons] = hsh[:taxons].split(",").compact }
  end

  def tag_content
    Services.publishing_api
      .patch_links(
        content_item.content_id,
        links: { taxons: submitted_taxons },
      )
  end

  def submitted_taxons
    params
      .require(:project_content_item)
      .permit(:taxons)
      .fetch(:taxons, "")
      .split(",")
  end

  def project
    @project ||= Project.find(params[:project_id])
  end

  def content_item
    @content_item ||= ProjectContentItem.find(params[:id])
  end
end
