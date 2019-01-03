class CircularDependencyValidator < ActiveModel::Validator
  def validate(record)
    return if record.content_id != record.parent_content_id

    record.errors[:parent_content_id] << I18n.t("errors.circular_dependency.on_self")
  end
end
