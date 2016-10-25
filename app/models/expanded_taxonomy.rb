class ExpandedTaxonomy
  attr_reader :parent_expansion, :child_expansion

  def initialize(content_id)
    @content_id = content_id
  end

  def build
    build_parent_expansion
    build_child_expansion
    self
  end

  def build_parent_expansion
    parent_taxons = Services.publishing_api.get_expanded_links(
      root_node.content_id
    )["expanded_links"]["parent_taxons"]

    @parent_expansion = expand_parent_nodes(
      start_node: tree_node_based_on(root_content_item),
      parent_taxons: parent_taxons,
    )
    self
  end

  def build_child_expansion
    @child_expansion = expand_child_nodes(
      start_node: tree_node_based_on(root_content_item)
    )
    self
  end

  def immediate_parents
    parent_expansion.children
  end

  def immediate_children
    child_expansion.children
  end

  def root_node
    @root_node ||= tree_node_based_on(root_content_item)
  end

  def parent_expansion
    if instance_variable_defined?(:@parent_expansion)
      @parent_expansion
    else
      raise ExpansionNotBuiltError
    end
  end

  def child_expansion
    if instance_variable_defined?(:@child_expansion)
      @child_expansion
    else
      raise ExpansionNotBuiltError
    end
  end

  class ExpansionNotBuiltError < StandardError
    def message
      "Call the appropriate build method to see a parent or child expansion"
    end
  end

private

  def root_content_item
    @root_content_item ||= Services.publishing_api.get_content(@content_id)
  end

  def expand_child_nodes(start_node:)
    child_taxons = Services.publishing_api.get_expanded_links(
      start_node.content_id
    )["expanded_links"]["child_taxons"]

    Array(child_taxons).each do |child_taxon|
      child_node = tree_node_based_on(child_taxon)
      start_node << child_node
      expand_child_nodes(start_node: child_node)
    end
    start_node
  end

  def expand_parent_nodes(start_node:, parent_taxons:)
    Array(parent_taxons).each do |parent_taxon|
      parent_node = tree_node_based_on(parent_taxon)
      start_node << parent_node
      expand_parent_nodes(
        start_node: parent_node,
        parent_taxons: parent_taxon.dig("links", "parent_taxons")
      )
    end
    start_node
  end

  def tree_node_based_on(content_item)
    TreeNode.new(title: content_item["title"], content_id: content_item["content_id"])
  end
end
