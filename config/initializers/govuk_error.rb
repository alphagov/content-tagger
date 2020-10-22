GovukError.configure do |config|
  config.data_sync_excluded_exceptions << "GdsApi::HTTPInternalServerError"
end
