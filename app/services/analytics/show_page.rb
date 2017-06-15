module Analytics
  class ShowPage
    attr_reader :id

    def initialize(taxon_id)
      @id = taxon_id
    end

    def title
      @_title ||= TaggingEvent.where(taxon_content_id: id).first.taxon_title
    end

    def tagging_events
      @_tagging_events ||= TaggingEvent.for_taxon_id(id).order(tagged_at: :desc)
    end

    def content_count_over_time
      weeks_in_period = (6.months.ago.to_date..Date.today).select(&:monday?)

      guidance_count_acc = TaggingEvent
        .guidance
        .for_taxon_id(id)
        .before(6.months.ago.to_date)
        .sum(:change)

      other_count_acc = TaggingEvent
        .other
        .for_taxon_id(id)
        .before(6.months.ago.to_date)
        .sum(:change)

      guidance_series = {}
      other_series = {}

      weeks_in_period.each do |week|
        taxon_events_in_week(week).each do |event|
          if event.guidance?
            guidance_count_acc += event.change
          else
            other_count_acc += event.change
          end
        end

        guidance_series[week] = guidance_count_acc
        other_series[week] = other_count_acc
      end

      [
        { name: "Guidance", data: guidance_series },
        { name: "Other content", data: other_series }
      ]
    end

  private

    def taxon_events_in_week(date_of_start_of_week)
      TaggingEvent
        .for_taxon_id(id)
        .since(date_of_start_of_week)
        .before(date_of_start_of_week.next_week)
        .order(tagged_at: :asc)
    end
  end
end
