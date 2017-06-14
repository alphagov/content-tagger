class TaggingEvent < ApplicationRecord
  scope :for_taxon_id, (lambda do |taxon_id|
    where(taxon_content_id: taxon_id)
  end)

  scope :taxon_events_in_week, (lambda do |taxon_id, date_of_start_of_week|
    self.for_taxon_id(taxon_id)
      .where("tagged_on >= ?", date_of_start_of_week)
      .where("tagged_on < ?", date_of_start_of_week.next_week)
      .order(tagged_at: :asc)
  end)

  def self.content_counts_by_taxon
    group(:taxon_title, :taxon_content_id)
      .sum(:change)
      .sort_by { |_, v| v }
      .reverse
      .map do |result|
        {
          title: result[0][0],
          id: result[0][1],
          count: result[1]
        }
      end
  end

  def self.content_count_over_time(taxon_id)
    weeks_in_period = (6.months.ago.to_date..Date.today).select(&:monday?)

    content_count_acc = 0

    weeks_in_period.reduce({}) do |acc, week|
      events = taxon_events_in_week(taxon_id, week)
      events.each do |e|
        content_count_acc += e.change
      end

      acc.merge(week => content_count_acc)
    end
  end

  def added?
    change.positive?
  end

  def removed?
    change.negative?
  end
end
