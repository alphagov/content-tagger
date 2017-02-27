require 'csv'

module Taxonomy
  class CsvTreePresenter
    def initialize(tree)
      @tree = tree
    end

    def present
      CSV.generate do |csv|
        @tree.each do |node|
          row = [node.title]
          node.depth.times { row.unshift nil }
          csv << row
        end
      end
    end
  end
end
