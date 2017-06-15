module Analytics
  class ActivityPage
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def user_names
      TaggingEvent.uniq.pluck(:user_name).sort
    end

    def user_organisations
      TaggingEvent.uniq.pluck(:user_organisation).compact.sort
    end

    def tagging_events
      scope = TaggingEvent
        .order(created_at: 'desc')
        .limit(1000)

      if params[:user_name]
        scope = scope.where(user_name: params[:user_name])
      end

      if params[:user_organisation]
        scope = scope.where(user_organisation: params[:user_organisation])
      end

      scope
    end
  end
end
