module Taxonomy
  class TaxonomySizePresenter < SimpleDelegator
    MAXIMUM_BAR_WIDTH_PERCENTAGE = 30

    def bar_width_percentage(size)
      return 0 if max_size.zero?
      (size * MAXIMUM_BAR_WIDTH_PERCENTAGE) / max_size
    end
  end
end
