module BulkTagging
  class UpdateTagsController < ApplicationController
    def create
      tag_migration.save!
      redirect_to tag_migration_path(tag_migration)

    rescue BulkTagging::BuildTagMigration::InvalidArgumentError => e
      flash[:error] = e.message
      redirect_to bulk_tagging_collection_path(params[:collection_content_id])
    end

  private

    def tag_migration
      @tag_migration ||= BulkTagging::BuildTagMigration.perform(
        original_link_content_id: params[:collection_content_id],
        taxon_content_ids: taxon_content_ids,
        content_base_paths: content_base_paths
      )
    end

    def taxon_content_ids
      params[:taxons]
    end

    def content_base_paths
      params[:content_base_paths]
    end
  end
end
