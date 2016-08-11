class GoogleUrlValidator < ActiveModel::Validator
  def validate(record)
    uri = URI.parse(record.url)

    validate_host(uri, record)
    validate_path(uri, record)
    validate_parameters(uri, record)
  end

private

  def validate_host(uri, record)
    unless uri.host == "docs.google.com"
      record.errors[:url] << I18n.t('errors.invalid_hostname')
    end
  end

  def validate_path(uri, record)
    unless uri.path =~ %r{spreadsheets\/d\/.+\/pub}
      record.errors[:url] << I18n.t('errors.invalid_path')
    end
  end

  def validate_parameters(uri, record)
    parameters = CGI.parse(uri.query || "")
    unless parameters['gid'].present?
      record.errors[:url] << I18n.t('errors.missing_gid')
    end

    unless parameters['output'].present? && parameters['output'].include?('tsv')
      record.errors[:url] << I18n.t('errors.missing_output')
    end
  end
end
