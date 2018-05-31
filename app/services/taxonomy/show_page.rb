module Taxonomy
  class ShowPage
    delegate :content_id, :draft?, :published?, :unpublished?, :redirected?,
             :redirect_to, :base_path, to: :taxon

    attr_reader :taxon, :visualisation

    def initialize(taxon, visualisation = "taxonomy_tree")
      @taxon = taxon
      @visualisation = visualisation
    end

    def title
      taxon.internal_name
    end

    def publication_state_name
      {
        "draft" => "draft",
        "published" => "published",
        "unpublished" => "deleted",
      }.fetch(taxon.publication_state)
    end

    def taxon_content_id
      taxon.content_id
    end

    def taxonomy_tree
      @taxonomy_tree ||= Taxonomy::ExpandedTaxonomy.new(taxon_content_id).build
    end

    def taxonomy_size
      @taxonomy_size ||= Taxonomy::TaxonsWithContentCountPresenter.new(
        Taxonomy::TaxonsWithContentCount.new(taxon)
      )
    end

    def children
      @children ||= taxonomy_tree.child_expansion.children
    end

    def chevron_hierarchy
      taxonomy_tree.parent_expansion.map(&:title).reverse.join(" > ")
    end

    def tagged
      @tagged ||= begin
        return [] if taxon.unpublished?

        Services.publishing_api.get_linked_items(
          taxon.content_id,
          link_type: "taxons",
          fields: %w[title content_id base_path document_type]
        )
      end
    end

    def taxons_for_select
      Linkables.new.taxons(exclude_ids: taxon_content_id)
    end

    def associated_taxons
      taxonomy_tree.associated_taxons
    end

    def taxon_deletable?
      taxon.content_id != GovukTaxonomy::ROOT_CONTENT_ID
    end

    def email_subscribers
      @email_subscribers ||= begin
        email_lists = []

        begin
          email_lists = Services.email_alert_api.find_subscriber_list(links: { taxon_tree: [taxon.content_id] })
        rescue GdsApi::BaseError, SocketError => e
          GovukError.notify(e)
        end

        subscriptions = email_lists.dig(0, "active_subscriptions_count")
        subscriptions.present? ? subscriptions : "?"
      end
    end
  end
end
