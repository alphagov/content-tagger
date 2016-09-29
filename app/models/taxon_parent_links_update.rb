class TaxonParentLinksUpdate
  attr_reader :content_id

  def initialize(content_id)
    @content_id = content_id
  end

  def links_to_update
    { 'parent' => [] }
  end
end
