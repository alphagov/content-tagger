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

  scope :guidance, -> { where(taggable_navigation_document_supertype: 'guidance') }
  scope :other, -> { where(taggable_navigation_document_supertype: 'other') }

  def self.content_counts_by_taxon
    taxons = group(:taxon_title, :taxon_content_id)
      .order(taxon_title: :asc)
      .count
      .map { |t| { title: t[0][0], id: t[0][1] } }

    counts = group(:taxon_content_id, :taggable_navigation_document_supertype).sum(:change)

    taxons.map do |taxon|
      {
        title: taxon[:title],
        id: taxon[:id],
        guidance_count: counts[[taxon[:id], 'guidance']] || 0,
        other_count: counts[[taxon[:id], 'other']] || 0
      }
    end
  end

  def self.content_count_over_time(taxon_id)
    weeks_in_period = (6.months.ago.to_date..Date.today).select(&:monday?)

    guidance_count_acc = guidance.for_taxon_id(taxon_id)
      .where("tagged_on < ?", 6.months.ago.to_date)
      .sum(:change)

    other_count_acc = other.for_taxon_id(taxon_id)
      .where("tagged_on < ?", 6.months.ago.to_date)
      .sum(:change)

    guidance_series = {}
    other_series = {}

    weeks_in_period.each do |week|
      events = taxon_events_in_week(taxon_id, week)
      events.each do |e|
        if e.guidance?
          guidance_count_acc += e.change
        else
          other_count_acc += e.change
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

  def guidance?
    taggable_navigation_document_supertype == 'guidance'
  end

  def added?
    change.positive?
  end

  def removed?
    change.negative?
  end
end
