class TaxonPathPrefixValidator < ActiveModel::Validator
  def validate(record)
    return if record.parent_content_id.blank?
    return if record.parent_content_id == GovukTaxonomy::ROOT_CONTENT_ID

    parent_taxon = Taxonomy::BuildTaxon.call(content_id: record.parent_content_id)

    return if record.path_prefix == parent_taxon.path_prefix

    record.errors[:base_path] << "must start with /#{parent_taxon.path_prefix}"
  end
end
