class TagMigrationsController < ApplicationController
  def show
    render :show, locals: {
      tag_migration: tag_migration,
      tag_mappings: presented_tag_mappings,
      confirmed: tag_mappings.completed.count,
      progress_path: tag_migration_import_progress_path(tag_migration),
    }
  end

  def publish_tags
    TagImporter::PublishTags.new(tag_migration, user: current_user).run

    redirect_to(
      tag_migration,
      success: I18n.t('controllers.tag_migrations.import_started')
    )
  end

  def index
    render :index, locals: { tag_migrations: presented_tag_migrations }
  end

  def destroy
    tag_migration.mark_as_deleted
    redirect_to(
      tag_migrations_path,
      success: I18n.t('controllers.tag_migrations.import_removed')
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
end
