class TagMigrationsController < ApplicationController
  def index
    render :index, locals: { tag_migrations: presented_tag_migrations }
  end

  def new
    unless params[:source_content_id]
      redirect_to new_tag_search_path
      return
    end

    source_content_item = ContentItem.find!(params[:source_content_id])

    expanded_links = BulkTagging::FetchTaggedContent.call(
      tag_content_id: source_content_item.content_id,
      tag_document_type: source_content_item.document_type,
    )

    render :new, locals: {
      tag_migration: TagMigration.new(source_content_id: source_content_item.content_id),
      taxons: Linkables.new.taxons,
      expanded_links: expanded_links,
      source_content_item: source_content_item,
    }
  end

  def create
    source_content_item = ContentItem.find!(params[:tag_migration][:source_content_id])

    tag_migration = BulkTagging::BuildTagMigration.call(
      source_content_item: source_content_item,
      taxon_content_ids: params[:taxons],
      content_base_paths: params[:content_base_paths],
    )

    tag_migration.save!
    redirect_to tag_migration_path(tag_migration)
  rescue BulkTagging::BuildTagMigration::InvalidArgumentError => e
    flash[:error] = e.message
    redirect_to new_tag_migration_path(source_content_id: source_content_item.content_id)
  end

  def show
    render :show, locals: {
      tag_migration: tag_migration,
      current_tagged_taxon: tag_migration.source_title,
      aggregated_tag_mappings: presented_aggregated_tag_mappings,
      completed_tag_mappings: aggregated_tag_mappings.sum(&:completed_tag_mappings),
      total_tag_mappings: aggregated_tag_mappings.sum(&:total_tag_mappings),
      progress_path: tag_migration_progress_path(tag_migration),
    }
  end

  def progress
    render partial: "tag_update_progress_bar", formats: :html, locals: {
      tag_mappings: aggregated_tag_mappings,
      completed_tag_mappings: aggregated_tag_mappings.sum(&:completed_tag_mappings),
      total_tag_mappings: aggregated_tag_mappings.sum(&:total_tag_mappings),
      progress_path: tag_migration_progress_path(tag_migration),
    }
  end

  def destroy
    tag_migration.mark_as_deleted
    redirect_to(
      tag_migrations_path,
      success: I18n.t('controllers.tag_migrations.import_removed')
    )
  end

  def publish_tags
    QueueLinksForPublishing.call(tag_migration, user: current_user)

    redirect_to(
      tag_migration,
      success: I18n.t('controllers.tag_migrations.import_started')
    )
  end

private

  def tag_migrations
    TagMigration.active.newest_first
  end

  def presented_tag_migrations
    tag_migrations.map do |tag_migration|
      TagMigrationPresenter.new(tag_migration)
    end
  end

  def tag_migration
    @tag_migration ||=
      TagMigration.find(params[:id] || params.fetch(:tag_migration_id))
  end

  def tag_mappings
    tag_migration.tag_mappings
      .by_state
      .by_content_base_path
      .by_link_title
  end

  def presented_tag_mappings
    tag_mappings.map do |tag_mapping|
      TagMappingPresenter.new(tag_mapping)
    end
  end

  def aggregated_tag_mappings
    tag_migration.aggregated_tag_mappings
  end

  def presented_aggregated_tag_mappings
    aggregated_tag_mappings.map do |aggregated_tag_mapping|
      AggregatedTagMappingPresenter.new(aggregated_tag_mapping)
    end
  end
end
