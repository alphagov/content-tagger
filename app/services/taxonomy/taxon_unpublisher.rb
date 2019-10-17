module Taxonomy
  class TaxonUnpublisher
    include BrexitTaxon

    def self.call(taxon_content_id:, redirect_to_content_id:, user:, retag: true)
      new.unpublish(taxon_content_id: taxon_content_id,
                    redirect_to_content_id: redirect_to_content_id,
                    user: user, retag: retag)
    end

    def unpublish(taxon_content_id:, redirect_to_content_id:, user:, retag:)
      tag_to_parent(taxon_content_id, user) if retag
      unpublish_taxon(taxon_content_id, redirect_to_content_id)
    end

  private

    def tag_to_parent(taxon_content_id, user)
      parent_taxon = Taxonomy::TaxonomyQuery.new.parent(taxon_content_id)
      return if parent_taxon.nil?

      content_base_paths = tagged_content_base_paths(taxon_content_id)
      return unless content_base_paths.present?

      tag_migration = BulkTagging::BuildTagMigration.call(
        source_content_item: ContentItem.find!(taxon_content_id),
        taxon_content_ids: [parent_taxon["content_id"]],
        content_base_paths: content_base_paths,
      )
      tag_migration.save!
      BulkTagging::QueueLinksForPublishing.call(tag_migration, user: user)
    end

    def unpublish_taxon(taxon_content_id, redirect_to_content_id)
      redirect_to_taxon = Services.publishing_api.get_content(redirect_to_content_id)
      publishing_api_unpublish(taxon_content_id, redirect_to_taxon["base_path"])
      return unless brexit_taxon?(taxon_content_id)

      publishing_api_unpublish(taxon_content_id, redirect_to_taxon["base_path"], "cy")
    end

    def tagged_content_base_paths(content_id)
      Services.publishing_api.get_linked_items(
        content_id,
        link_type: "taxons",
        fields: %w[base_path],
      ).map { |content| content["base_path"] }
    end

    def publishing_api_unpublish(content_id, redirect, locale = nil)
      params = {
        type: "redirect",
        alternative_path: redirect,
      }
      params[:locale] = locale if locale

      Services.publishing_api.unpublish(content_id, params)
    end
  end
end
