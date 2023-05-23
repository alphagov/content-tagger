require "govuk_app_config/govuk_prometheus_exporter"
GovukPrometheusExporter.configure

PROMETHEUS_PUSHGATEWAY_URL = ENV["PROMETHEUS_PUSHGATEWAY_URL"]
