module Taxonomy
  class ExpandedTaxonomy
    def initialize(content_id)
      @content_id = content_id
    end

    def build
      build_parent_expansion
      if @content_id == GovukTaxonomy::ROOT_CONTENT_ID
        build_child_expansion_for_home_page
      else
        build_child_expansion
        @parent_expansion.tree.last << home_page_linked_content_item if attached_to_root?(@parent_expansion.tree.last.content_id)
      end
      self
    end

    def associated_taxons
      root_expanded_links.dig('expanded_links', 'associated_taxons')
    end

    def immediate_parents
      parent_expansion.children
    end

    def multiple_immediate_parents?
      immediate_parents.count > 1
    end

    def immediate_children
      child_expansion.children
    end

    def multiple_immediate_children?
      immediate_children.count > 1
    end

    def root_node
      @root_node ||= tree_node_based_on(root_content_item)
    end

    def parent_expansion
      raise ExpansionNotBuiltError unless instance_variable_defined?(:@parent_expansion)
      @parent_expansion
    end

    def child_expansion
      raise ExpansionNotBuiltError unless instance_variable_defined?(:@child_expansion)
      @child_expansion
    end

    class ExpansionNotBuiltError < StandardError
      def message
        "Call the appropriate build method to see a parent or child expansion"
      end
    end

  private

    def root_content_item
      @root_content_item ||= Services.publishing_api.get_content(@content_id).to_h
    end

    def attached_to_root?(content_id)
      Services.publishing_api.get_expanded_links(content_id).dig('expanded_links', 'root_taxon').present?
    end

    def expand_parent_nodes(start_node:, parent:)
      return start_node unless parent

      parent_node = tree_node_based_on(parent)

      start_node << parent_node

      expand_parent_nodes(
        start_node: parent_node,
        parent: parent.dig('links', 'parent_taxons', 0),
      )

      start_node
    end

    def tree_node_based_on(content_item)
      if content_item['content_id'] == GovukTaxonomy::ROOT_CONTENT_ID
        home_page_linked_content_item
      else
        GovukTaxonomyHelpers::LinkedContentItem.new(
          internal_name: content_item.dig('details', 'internal_name'),
          title: content_item.fetch('title'),
          base_path: content_item.fetch('base_path'),
          content_id: content_item.fetch('content_id')
        )
      end
    end

    def home_page_linked_content_item
      GovukTaxonomyHelpers::LinkedContentItem.new(
        internal_name: GovukTaxonomy::TITLE,
        title: GovukTaxonomy::TITLE,
        base_path: '/',
        content_id: GovukTaxonomy::ROOT_CONTENT_ID
      )
    end

    def root_expanded_links
      @expanded_links ||= Services.publishing_api.get_expanded_links(
        @content_id
      )
    end

    def build_parent_expansion
      @parent_expansion = expand_parent_nodes(
        start_node: root_node,
        parent: root_expanded_links.dig('expanded_links', 'parent_taxons', 0),
        )
      self
    end

    def build_child_expansion
      @child_expansion = GovukTaxonomyHelpers::LinkedContentItem.from_content_id(
        content_id: @content_id,
        publishing_api: Services.publishing_api,
      )

      # We want to work with the child expansion in isolation, so remove
      # the parent. This makes all depth values relative to the current taxon.
      @child_expansion.parent = nil

      self
    end

    def build_child_expansion_for_home_page
      @child_expansion = home_page_linked_content_item.tap do |node|
        LevelOneTaxonsRetrieval.new.get.each do |level_one_taxon|
          node << GovukTaxonomyHelpers::LinkedContentItem.from_content_id(
            content_id: level_one_taxon['content_id'],
            publishing_api: Services.publishing_api
          )
        end
      end
    end
  end
end
