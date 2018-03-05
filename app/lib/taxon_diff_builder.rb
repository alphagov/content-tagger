class TaxonDiffBuilder
  def initialize(previous_item:, current_item:)
    @previous_fields = fields_for(previous_item)
    @current_fields = fields_for(current_item)
  end

  def diff
    HashDiff.diff(previous_fields, current_fields)
  end

private

  attr_reader :previous_fields, :current_fields

  def fields_for(taxon)
    return {} if taxon.blank?

    %i[
      parent_content_id
      base_path
      internal_name
      title
      description
      notes_for_editors
      associated_taxons
      phase
    ].each_with_object({}) do |field, hash|
      hash[field] = taxon.send(field)
    end
  end
end
