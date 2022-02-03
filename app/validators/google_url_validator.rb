class GoogleUrlValidator < ActiveModel::Validator
  def validate(record)
    uri = URI.parse(record.url)

    validate_host(uri, record)
    validate_path(uri, record)
    validate_parameters(uri, record)
  end

private

  def validate_host(uri, record)
    return if uri.host == "docs.google.com"

    record.errors.add(:url, I18n.t("errors.invalid_hostname"))
  end

  def validate_path(uri, record)
    return if uri.path.match?(%r{spreadsheets/d/.+/pub})

    record.errors.add(:url, I18n.t("errors.invalid_path"))
  end

  def validate_parameters(uri, record)
    parameters = CGI.parse(uri.query || "")
    if parameters["gid"].blank?
      record.errors.add(:url, I18n.t("errors.missing_gid"))
    end

    unless parameters["output"].present? && parameters["output"].include?("csv")
      record.errors.add(:url, I18n.t("errors.missing_output"))
    end
  end
end
