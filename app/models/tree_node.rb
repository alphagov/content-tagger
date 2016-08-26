class TreeNode
  attr_reader :taxon, :children, :node_depth
  attr_accessor :parent
  delegate :title, :content_id, :parent_taxons, :parent_taxons=, to: :taxon
  delegate :map, :each, to: :children

  def initialize(taxon_hash)
    @taxon = Taxon.new(taxon_hash)
    @children = []
  end

  def add_children(children)
    @children << children
  end

  def children
    return [self] if @children.empty?

    _children = [self]
    @children.each do |ch|
      _children.concat(ch.children)
    end

     _children
  end

  def first
    children.first
  end

  def root?
    parent.nil?
  end

  def name
    title
  end

  def node_depth
    return 0 if root?
    1 + parent.node_depth
  end

  def count
    children.count
  end
end
