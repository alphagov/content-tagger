class TaggingEvent < ActiveRecord::Base
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
