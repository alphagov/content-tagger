class ContentIdValidator < ActiveModel::Validator
  def validate(record)
    return if record.content_id.present?

    record.errors[:content_id] << I18n.t("tag_import.errors.invalid_content_id")
  end
end
