class ExpandedTaxonomy
  def initialize(content_id)
    @content_id = content_id
  end

  def build
    root_content_item = Services.publishing_api.get_content(@content_id)
    root_node = tree_node_based_on(root_content_item)
    expand_tree_from(root_node)
    root_node
  end

private

  def expand_tree_from(node)
    expanded_links = Services.publishing_api.get_expanded_links(
      node.content_id
    )["expanded_links"]

    add_parent_details(node, expanded_links)
    add_children(node, expanded_links)
  end

  def add_parent_details(node, expanded_links)
    # Collect identifying info about the node's parent taxons and store this on
    # the node itself.
    node.parent_taxons = Array(expanded_links["parent_taxons"]).map do |parent_taxon|
      Taxon.new(parent_taxon.to_hash.slice('title', 'content_id'))
    end
  end

  def add_children(node, expanded_links)
    # Derive a tree node from each child taxon, attach it to the parent, and
    # recursively expand from the child node downwards.
    Array(expanded_links["child_taxons"]).each do |child_taxon|
      child_node = tree_node_based_on(child_taxon)
      node << child_node
      expand_tree_from(child_node)
    end
  end

  def tree_node_based_on(content_item)
    TreeNode.new(title: content_item["title"], content_id: content_item["content_id"])
  end
end
