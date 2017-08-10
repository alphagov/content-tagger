module GovukTaxonomy
  class Branches
    HOMEPAGE_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a".freeze

    def branch_name_for_content_id(content_id)
      get_content_item(content_id).dig('title')
    end

    def all
      published.map { |taxon| transform(taxon, 'published') } +
        draft.map { |taxon| transform(taxon, 'draft') }
    end

    def published
      @_published_branches ||= get_root_taxons(with_drafts: false)
    end

    def draft
      @_draft_branches ||= get_root_taxons(with_drafts: true) - published
    end

    def taxons_for_branch(content_id)
      taxon = get_content_item(content_id)
      taxon['expanded_links_hash'] = get_expanded_links_hash(content_id, with_drafts: true)
      Tree.new(taxon).root_taxon.tree
    end

  private

    def transform(taxon, status)
      taxon.slice("content_id", "title").merge("status" => status)
    end

    def get_root_taxons(with_drafts:)
      get_expanded_links_hash(HOMEPAGE_CONTENT_ID, with_drafts: with_drafts)
        .fetch('expanded_links', {})
        .fetch('root_taxons', [])
    end

    def get_expanded_links_hash(content_id, with_drafts:)
      Services.publishing_api
        .get_expanded_links(content_id, with_drafts: with_drafts)
        .to_h
    end

    def get_content_item(content_id)
      Services.publishing_api.get_content(content_id).to_h
    end
  end
end
