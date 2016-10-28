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

  def expand_child_nodes(start_node:, already_expanded: [])
    return if already_expanded.include? start_node.content_id
    already_expanded << start_node.content_id

    child_taxons = Services.publishing_api.get_expanded_links(
      start_node.content_id
    )["expanded_links"]["child_taxons"]

    Array(child_taxons).each do |child_taxon|
      child_node = tree_node_based_on(child_taxon)
      start_node << child_node
      # We reset the list of already_expanded nodes with each branch off the
      # root taxon, i.e. - for each immediate child of the root. This gives
      # each of these 'main' branches their own traversal history, preventing
      # premature termination of a branch's expansion just because a node has
      # already been visited in a sibling branch.
      expansion_history = child_node.node_depth == 1 ? [root_node.content_id] : already_expanded
      expand_child_nodes(start_node: child_node, already_expanded: expansion_history)
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
