class TaggingEvent < ApplicationRecord
  scope :for_taxon_id, (lambda do |taxon_id|
    where(taxon_content_id: taxon_id)
  end)

  scope :before, (lambda do |datetime|
    where("tagged_on < ?", datetime)
  end)

  scope :since, (lambda do |datetime|
    where("tagged_on >= ?", datetime)
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
