module Taxonomy
  class HealthWarningsController < ApplicationController
    # GET /taxonomy/health_warnings
    def index
      @taxonomy_health_warnings = Taxonomy::HealthWarning.all
    end
  end
end
