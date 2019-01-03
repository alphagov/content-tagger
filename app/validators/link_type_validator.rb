class LinkTypeValidator < ActiveModel::Validator
  def validate(record)
    return if record.link_type == 'taxons'

    record.errors[:link_type] << I18n.t('tag_import.errors.invalid_link_types')
  end
end
