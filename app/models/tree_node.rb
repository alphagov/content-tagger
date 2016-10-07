class TreeNode
  attr_reader :taxon
  attr_accessor :parent
  delegate :title, :content_id, :parent_taxons, :parent_taxons=, to: :taxon
  delegate :map, :each, to: :tree

  def initialize(title:, content_id:)
    @taxon = Taxon.new(title: title, content_id: content_id)
    @children = []
  end

  def <<(child_node)
    child_node.parent = self
    @children << child_node
  end

  def tree
    return [self] if @children.empty?

    @children.each_with_object([self]) do |child, tree|
      tree.concat(child.tree)
    end
  end

  def count
    tree.count
  end

  def root?
    parent.nil?
  end

  def node_depth
    return 0 if root?
    1 + parent.node_depth
  end
end
