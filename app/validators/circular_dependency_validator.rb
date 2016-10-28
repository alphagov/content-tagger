class CircularDependencyValidator < ActiveModel::Validator
  def validate(record)
    if record.content_id.in? record.parent_taxons
      record.errors[:parent_taxons] << I18n.t("errors.circular_dependency.on_self")
    end
  end
end
