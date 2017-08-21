class ProjectContentItemsController < ApplicationController
  def update
    tag_content
    content_item.mark_complete
    head :ok
  rescue GdsApi::HTTPClientError
    head :bad_request
  end

  def bulk_update
    tagger = Projects::BulkTagger.new(bulk_params)
    tagger.commit
    render json: tagger.result
  end

private

  def bulk_params
    params
      .require(:bulk_tagging)
      .permit(:taxons, content_items: [])
      .to_h
      .symbolize_keys
      .tap { |hsh| hsh[:taxons] = hsh[:taxons].split(',').compact }
  end

  def tag_content
    Services.publishing_api
      .patch_links(
        content_item.content_id,
        links: { taxons: submitted_taxons }
      )
  end

  def submitted_taxons
    params
      .require(:project_content_item)
      .permit(:taxons)
      .fetch(:taxons, "")
      .split(',')
  end

  def project
    @_project ||= Project.find(params[:project_id])
  end

  def content_item
    @_content_item ||= ProjectContentItem.find(params[:id])
  end
end
