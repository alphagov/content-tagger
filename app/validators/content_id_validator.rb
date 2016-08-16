class ContentIdValidator < ActiveModel::Validator
  def validate(record)
    if record.content_id.blank?
      record.errors[:content_id] << I18n.t('tag_import.errors.invalid_content_id')
    end
  end
end
