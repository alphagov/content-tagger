class CircularDependencyValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:parent] << I18n.t("errors.circular_dependency.on_self") if record.content_id == record.parent
  end
end
