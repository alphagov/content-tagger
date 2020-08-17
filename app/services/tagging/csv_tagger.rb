module Tagging
  class CsvTagger
    def self.do_tagging(url)
      taggings = RemoteCsv.new(url).rows_with_headers
      grouped_tags = taggings.group_by { |tagging| tagging["content_id"] }
      grouped_tags.each do |content_id, grouped_taggings|
        taxon_ids = grouped_taggings.map { |t| t["taxon_id"] }
        yield(content_id: content_id, taxon_ids: taxon_ids) if block_given?
        Tagging::Tagger.add_tags(content_id, grouped_taggings.map { |t| t["taxon_id"] }, :taxons)
      end
    end
  end
end
