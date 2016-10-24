class TreeNode
  attr_reader :taxon, :children
  attr_accessor :parent_node
  delegate :title, :base_path, :content_id, to: :taxon
  delegate :map, :each, to: :tree

  def initialize(title:, content_id:)
    @taxon = Taxon.new(title: title, content_id: content_id)
    @children = []
  end

  def <<(child_node)
    child_node.parent_node = self
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
    parent_node.nil?
  end

  def node_depth
    return 0 if root?
    1 + parent_node.node_depth
  end
end
