class TagMigrationsController < ApplicationController
  def index
    render :index, locals: { tag_migrations: presented_tag_migrations }
  end

  def new
    unless tag_migration_params_present?
      redirect_to new_tag_search_path
      return
    end

    expanded_links = BulkTagging::TaggedContentFetcher.fetch(
      tag_migration_params[:source_content_id],
      tag_migration_params[:document_type],
    )
    taxons = Taxonomy::TaxonFetcher.new.taxons

    render :new, locals: {
      tag_migration: TagMigration.new(tag_migration_params),
      taxons: taxons,
      expanded_links: expanded_links,
    }
  end

  def create
    tag_migration = BulkTagging::BuildTagMigration.perform(
      tag_migration_params: tag_migration_params,
      taxon_content_ids: params[:taxons],
      content_base_paths: params[:content_base_paths],
    )
    tag_migration.save!
    redirect_to tag_migration_path(tag_migration)
  rescue BulkTagging::BuildTagMigration::InvalidArgumentError => e
    flash[:error] = e.message
    redirect_to new_tag_migration_path(tag_migration: tag_migration_params)
  end

  def show
    render :show, locals: {
      tag_migration: tag_migration,
      tag_mappings: presented_tag_mappings,
      confirmed: tag_mappings.completed.count,
      progress_path: tag_migration_progress_path(tag_migration),
    }
  end

  def progress
    render partial: "tag_update_progress_bar", formats: :html, locals: {
      tag_mappings: tag_mappings,
      confirmed: tag_mappings.completed.count,
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
    TagImporter::PublishTags.new(tag_migration, user: current_user).run

    redirect_to(
      tag_migration,
      success: I18n.t('controllers.tag_migrations.import_started')
    )
  end

private

  def tag_migration_params_present?
    return false if params[:tag_migration].blank?
    tag_migration_params.map { |_, v| v.present? }.all?
  end

  def tag_migration_params
    params.require(:tag_migration).permit(
      :source_base_path, :source_content_id, :document_type, :query
    )
  end

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
end
