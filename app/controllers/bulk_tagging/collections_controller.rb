module BulkTagging
  class CollectionsController < ApplicationController
    def show
      expanded_links = ExpandedLinksFetcher.expanded_links(params[:content_id])
      taxons = Taxonomy::TaxonFetcher.new.taxons

      render :show, locals: {
        bulk_tagging: TagMigration.new,
        content_id: params[:content_id],
        base_path: params[:base_path],
        taxons: taxons,
        expanded_links: expanded_links,
        query: params[:query]
      }
    end
  end
end
