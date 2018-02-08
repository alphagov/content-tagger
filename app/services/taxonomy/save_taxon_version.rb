module Taxonomy
  class SaveTaxonVersion
    def self.call(taxon, version_note)
      new(taxon, version_note).save
    end

    def initialize(taxon, version_note)
      @taxon = taxon
      @version_note = version_note
    end

    def save
      return if no_change_to_record

      Version.create(
        content_id: content_id,
        object_changes: taxon_changes,
        note: version_note
      )
    end

  private

    attr_reader :version_note, :taxon
    delegate :content_id, to: :taxon

    def no_change_to_record
      version_note.blank? && taxon_changes.blank?
    end

    def taxon_changes
      @_taxon_changes ||= begin
        TaxonDiffBuilder.new(previous_item: previous_taxon, current_item: taxon).diff
      end
    end

    def previous_taxon
      @_previous_taxon ||= begin
        Taxonomy::BuildTaxon.call(content_id: content_id)
      rescue Taxonomy::BuildTaxon::TaxonNotFoundError
        nil
      end
    end
  end
end
