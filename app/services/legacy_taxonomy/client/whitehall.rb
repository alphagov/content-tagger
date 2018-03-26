module LegacyTaxonomy
  module Client
    class Whitehall
      class << self
        def policies_for_policy_area(policy_area_slug)
          client.get_policy_area(policy_area_slug)
            .to_h
            .fetch('classification_policies', [])
            .map { |policy| policy['policy_content_id'] }
        end

        def client
          @_client ||= GdsApi::Whitehall.new(
            Plek.new.find('whitehall-admin'),
            timeout: 20
          )
        end
      end
    end
  end
end

module GdsApi
  class Whitehall < Base
    def get_policy_area(slug)
      request_path = "#{endpoint}/government/admin/topics/#{slug}.json"
      get_json(request_path)
    end
  end
end
