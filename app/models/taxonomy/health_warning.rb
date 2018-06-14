module Taxonomy
  class HealthWarning < ActiveRecord::Base
    def to_s
      "#<Taxnomy::HealthWarning: #{message}>"
    end
  end
end
