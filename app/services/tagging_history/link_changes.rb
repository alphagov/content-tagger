module TaggingHistory
  class LinkChanges
    def initialize(params)
      @params = params
    end

    def changes
      @_changes ||= link_changes_from_publishing_api.map do |change|
        user = User.find_by_uid(change[:user_uid])

        if user.present?
          change[:user_uid] = user.uid
          change[:user_name] = user.name
          change[:organisation] = user.organisation_slug.try do |slug|
            slug.capitalize.tr('-', ' ')
          end
        end

        change
      end
    end

    def filter_by_user_options
      changes.each_with_object({}) do |change, options|
        next unless change.key? :user_uid
        options[change[:user_name]] = change[:user_uid]
      end
    end

  private

    def link_changes_from_publishing_api
      Services.link_changes_api
        .get_link_changes(
          { link_types: ['taxons'] }.merge(@params)
        )
        .to_hash
        .deep_symbolize_keys[:link_changes]
    end
  end
end
