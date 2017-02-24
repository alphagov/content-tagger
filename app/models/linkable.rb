class Linkable < ContentItem
  MISSING_INTERNAL_NAME_DOCUMENT_TYPES = %w(need organisation).freeze

  def valid_internal_name?
    internal_name.present?
  end

  def internal_name
    @internal_name ||= begin
      return title if missing_internal_name?

      details['internal_name']
    end
  end

private

  def missing_internal_name?
    MISSING_INTERNAL_NAME_DOCUMENT_TYPES.include?(document_type)
  end
end
