class AggregatedTagMappingPresenter < SimpleDelegator
  def errored?
    presented_tag_mappings.any? do |tag_mapping|
      tag_mapping.errored?
    end
  end

  def error_messages
    presented_tag_mappings.flat_map do |tag_mapping|
      tag_mapping.messages
    end
  end

private

  def presented_tag_mappings
    tag_mappings.map do |tag_mapping|
      TagMappingPresenter.new(tag_mapping)
    end
  end
end
