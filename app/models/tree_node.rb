class TreeNode
  attr_reader :name, :content_item, :children
  attr_accessor :parent_node
  delegate :content_id, to: :content_item
  delegate :map, :each, to: :tree

  def initialize(name:, content_item:)
    @name = name
    @content_item = content_item
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
