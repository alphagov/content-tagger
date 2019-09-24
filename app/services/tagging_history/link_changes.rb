module TaggingHistory
  class LinkChanges
    def initialize(params)
      @params = params
    end

    def changes
      @changes ||= link_changes_from_publishing_api.map do |change|
        user = User.find_by_uid(change[:user_uid])

        if user.present?
          change[:user_uid] = user.uid
          change[:user_name] = user.name
          change[:organisation] = user.organisation_slug.try do |slug|
            slug.capitalize.tr("-", " ")
          end
        end

        change
      end
    end

  private

    def link_changes_from_publishing_api
      Services.publishing_api
        .get_links_changes(
          { link_types: %w[taxons] }.merge(@params.to_h.symbolize_keys),
        )
        .to_hash
        .deep_symbolize_keys[:link_changes]
    end
  end
end
