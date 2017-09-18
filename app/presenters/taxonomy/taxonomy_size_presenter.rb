module Taxonomy
  class TaxonomySizePresenter < SimpleDelegator
    MAXIMUM_BAR_WIDTH_PERCENTAGE = 30

    def bar_width_percentage(size)
      (size * MAXIMUM_BAR_WIDTH_PERCENTAGE) / max_size
    end
  end
end
