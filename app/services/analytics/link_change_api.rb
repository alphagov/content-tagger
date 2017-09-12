module Analytics
  class LinkChangeApi < GdsApi::Base
    def get_link_changes(params = {link_types: ['taxons']})
      get_json(link_changes_url(params))
    end

    private

    def link_changes_url(params = {})
      query = query_string(params)
      "#{endpoint}/v2/links/changes#{query}"
    end
  end
end