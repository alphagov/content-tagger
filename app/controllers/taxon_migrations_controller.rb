class TaxonMigrationsController < ApplicationController
  before_action :ensure_user_can_manage_taxonomy!

  def new
    unless params[:source_content_id]
      redirect_to taxons_path
      return
    end

    source_content_item = ContentItem.find!(params[:source_content_id])

    expanded_links = BulkTagging::FetchTaggedContent.call(
      tag_content_id: source_content_item.content_id,
      tag_document_type: source_content_item.document_type,
    )

    render :new,
           locals: {
             tag_migration: BulkTagging::TagMigration.new(source_content_id: source_content_item.content_id),
             taxons: Linkables.new.taxons,
             expanded_links: expanded_links,
             source_content_item: source_content_item,
           }
  end

  def create
    source_content_item = ContentItem.find!(params[:bulk_tagging_tag_migration][:source_content_id])

    tag_migration = BulkTagging::BuildTagMigration.call(
      source_content_item: source_content_item,
      taxon_content_ids: params[:taxons],
      content_base_paths: params[:content_base_paths],
    )
    tag_migration.delete_source_link = true
    tag_migration.save!

    redirect_to tag_migration_path(tag_migration)
  rescue BulkTagging::BuildTagMigration::InvalidArgumentError => e
    flash[:error] = e.message
    redirect_to new_taxon_migration_path(source_content_id: source_content_item.content_id)
  end
end
