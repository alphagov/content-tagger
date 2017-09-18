module TaggingHistory
  class IndexPage
    attr_reader :link_changes, :filter_by_user_options

    def initialize(params = {link_types: ['taxons']})
      @filter_by_user_options = {}
      @link_changes = get_link_changes(params)
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
          @filter_by_user_options[user.name] = user.uid
          result[:organisation] = user.organisation_slug.try do |slug|
            slug.capitalize.tr('-', ' ')
          end
        end
      end

      # The Publishing API returns the results ordered so that the
      # latest come last. Reverse this so that the latest events are
      # displayed first.
      results.reverse
    end
  end
end
