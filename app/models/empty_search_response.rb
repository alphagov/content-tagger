class EmptySearchResponse
  def results
    []
  end

  def current_page
    1
  end

  def total_pages
    0
  end

  def limit_value
    5
  end
end
