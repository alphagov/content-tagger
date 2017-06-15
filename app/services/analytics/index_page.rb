module Analytics
  class IndexPage
    def taxons
      taxons = TaggingEvent.group(:taxon_title, :taxon_content_id)
        .order(taxon_title: :asc)
        .count
        .map { |t| { title: t[0][0], id: t[0][1] } }

      counts = TaggingEvent.group(:taxon_content_id, :taggable_navigation_document_supertype)
        .sum(:change)

      taxons.map do |taxon|
        {
          title: taxon[:title],
          id: taxon[:id],
          guidance_count: counts[[taxon[:id], 'guidance']] || 0,
          other_count: counts[[taxon[:id], 'other']] || 0
        }
      end
    end
  end
end
