class AggregatedTagMappingPresenter < SimpleDelegator
  def errored?
    presented_tag_mappings.any?(&:errored?)
  end

  def error_messages
    presented_tag_mappings.flat_map(&:messages)
  end

  def presented_tag_mappings
    tag_mappings.map do |tag_mapping|
      TagMappingPresenter.new(tag_mapping)
    end
  end
end
