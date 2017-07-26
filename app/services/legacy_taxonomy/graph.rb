require 'graphviz'

module LegacyTaxonomy
  class Graph
    attr_reader :root_taxon, :graph, :filename

    def initialize(taxonomy, filename)
      @root_taxon = taxonomy
      @graph = GraphViz.new(:G, rankdir: 'LR', type: :digraph)
      @filename = filename
    end

    def plot
      build_graph(root_taxon)
      graph.output(png: filename)
    end

    def build_graph(taxon)
      parent = graph.add_nodes("#{taxon.title} (#{taxon.tagged_pages.count})")
      taxon.child_taxons.each do |node|
        child = graph.add_nodes("#{node.title} (#{node.tagged_pages.count})")
        graph.add_edges(parent, child)
        build_graph(node)
      end
    end
  end
end
