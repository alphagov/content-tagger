class ExpandedTaxonomy
  attr_reader :root_node, :parent_expansion, :child_expansion

  def initialize(content_id)
    @content_id = content_id
  end

  def build
    root_content_item = Services.publishing_api.get_content(@content_id)
    @root_node = tree_node_based_on(root_content_item)

    parent_taxons = Services.publishing_api.get_expanded_links(
      @root_node.content_id
    )["expanded_links"]["parent_taxons"]

    @parent_expansion = expand_parent_nodes(
      start_node: tree_node_based_on(root_content_item),
      parent_taxons: parent_taxons,
    )
    @child_expansion = expand_child_nodes(
      start_node: tree_node_based_on(root_content_item)
    )

    self
  end

  def immediate_parents
    @parent_expansion.children
  end

  def immediate_children
    @child_expansion.children
  end

private

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
