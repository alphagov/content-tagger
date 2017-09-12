module Analytics
  class IndexPage

    attr_reader :link_changes

    def initialize(params = {})
      @params = params
      @link_changes = get_link_changes
    end

  private

    def get_link_changes
      results = Services.link_changes_api
                  .get_link_changes(link_types: ['taxons'])
                  .to_hash
                  .deep_symbolize_keys[:link_changes]

      results.each do |result|
        user = User.find_by_uid(result[:user_uid])
        if user.present?
          result[:user_name] = user.name
          result[:organisation] = user.organisation_slug.capitalize.gsub('-', ' ')
        end
      end
      results

    end

  end
end