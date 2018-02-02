class VersionPresenter < SimpleDelegator
  def changes
    object_changes.map do |modifier, attribute, *values|
      case modifier
      when '+'
        values.unshift(nil)
      when '-'
        values.push(nil)
      end

      [attribute, values]
    end
  end
end
