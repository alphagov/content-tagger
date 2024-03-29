module Taxonomy
  # A LinkedContentItem can be anything that has a content store representation
  # on GOV.UK.
  #
  # It can be used with "taxon" content items (a topic in the taxonomy) or
  # other document types that link to taxons.
  #
  # Taxon instances can have an optional parent and any number of child taxons.
  class LinkedContentItem
    extend Forwardable
    attr_reader :title, :content_id, :base_path, :children, :internal_name, :taxons
    attr_accessor :parent

    def_delegators :tree, :map, :each, :count

    # Use the publishing API service to fetch and extract a LinkedContentItem
    #
    # @param content_id [String] id of the content
    # @param publishing_api [GdsApi::PublishingApi] Publishing API service
    # @return [LinkedContentItem]
    def self.from_content_id(content_id:, publishing_api:)
      PublishingApiResponse.new(
        content_item: publishing_api.get_content(content_id).to_h,
        expanded_links: publishing_api.get_expanded_links(content_id).to_h,
        publishing_api:,
      ).linked_content_item
    end

    # @param title [String] the user facing name for the content item
    # @param base_path [String] the relative URL, starting with a leading "/"
    # @param content_id [UUID] unique identifier of the content item
    # @param internal_name [String] an internal name for the content item
    def initialize(title:, base_path:, content_id:, internal_name: nil)
      @title = title
      @internal_name = internal_name
      @content_id = content_id
      @base_path = base_path
      @children = []
      @taxons = []
    end

    # Add a LinkedContentItem as a child of this one
    def <<(child_node)
      child_node.parent = self
      @children << child_node
    end

    # Get taxons in the taxon's branch of the taxonomy.
    #
    # @return [Array] all taxons in this branch of the taxonomy, including the content item itself
    def tree
      return [self] if @children.empty?

      @children.each_with_object([self]) do |child, tree|
        tree.concat(child.tree)
      end
    end

    # Get descendants of a taxon
    #
    # @return [Array] all taxons in this branch of the taxonomy, excluding the content item itself
    def descendants
      tree.tap(&:shift)
    end

    # Get ancestors of a taxon
    #
    # @return [Array] all taxons in the path from the root of the taxonomy to the parent taxon
    def ancestors
      if parent.nil?
        []
      else
        parent.ancestors + [parent]
      end
    end

    # Get a breadcrumb trail for a taxon
    #
    # @return [Array] all taxons in the path from the root of the taxonomy to this taxon
    def breadcrumb_trail
      ancestors + [self]
    end

    # Get all linked taxons and their ancestors
    #
    # @return [Array] all taxons that this content item can be found in
    def taxons_with_ancestors
      taxons.flat_map(&:breadcrumb_trail)
    end

    # @return [Boolean] whether this taxon is the root of its taxonomy
    def root?
      parent.nil?
    end

    # @return [Integer] the number of taxons between this taxon and the taxonomy root
    def depth
      return 0 if root?

      1 + parent.depth
    end

    # Link this content item to a taxon
    #
    # @param taxon_node [LinkedContentItem] A taxon content item
    def add_taxon(taxon_node)
      taxons << taxon_node
    end

    # @return [String] the string representation of the content item
    def inspect
      if internal_name.nil?
        "LinkedContentItem(title: '#{title}', content_id: '#{content_id}', base_path: '#{base_path}')"
      else
        "LinkedContentItem(title: '#{title}', internal_name: '#{internal_name}', content_id: '#{content_id}', base_path: '#{base_path}')"
      end
    end
  end
end
