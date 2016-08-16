class LinkTypeValidator < ActiveModel::Validator
  def validate(record)
    if record.link_types != ['taxons']
      record.errors[:link_types] << I18n.t('tag_import.errors.invalid_link_types')
    end
  end
end
