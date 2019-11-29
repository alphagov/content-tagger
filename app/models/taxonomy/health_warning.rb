module Taxonomy
  class HealthWarning < ApplicationRecord
    def to_s
      "#<Taxnomy::HealthWarning: #{message}>"
    end
  end
end
