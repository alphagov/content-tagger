module Taxonomy
  class HealthWarningsController < ApplicationController
    # GET /taxonomy/health_warnings
    def index
      @taxonomy_health_warnings = Taxonomy::HealthWarning.all
    end

  private

    def taxonomy_health_warning_counts
      @taxonomy_health_warnings.each_with_object(Hash.new(0)) do |warning, counts|
        counts[warning.metric.constantize::DESCRIPTION] += 1
      end
    end

    helper_method :taxonomy_health_warning_counts
  end
end
