module Analytics
  class IndexPage
    attr_reader :link_changes

    def initialize(params = {link_types: ['taxons']})
      @link_changes = get_link_changes(params)
    end

    def users
      @link_changes.map {|link_change| link_change.slice(:user_uid, :user_name)}.compact.uniq
    end

  private

    def get_link_changes(params)
      results = Services.link_changes_api
                  .get_link_changes(params)
                  .to_hash
                  .deep_symbolize_keys[:link_changes]

      results.each do |result|
        user = User.find_by_uid(result[:user_uid])
        if user.present?
          result[:user_uid] = user.uid
          result[:user_name] = user.name
          result[:organisation] = user.organisation_slug.try do |slug|
            slug.capitalize.gsub('-', ' ')
          end
        end
      end

      results
    end
  end
end
