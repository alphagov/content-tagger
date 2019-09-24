module Support
  class TaxonHelper
    def self.expanded_link_hash(content_id, paths)
      path_converter = lambda do |path|
        head, *tail = path

        return {} if head.nil?

        links_hash =
          if tail.empty?
            {}
          else
            {
              "links" =>
               {
                 tail.length == 1 ? "root_taxon" : "parent_taxons" => [path_converter.call(tail)],
               },
            }
          end
        {
          "content_id" => head,
        }.merge(links_hash)
      end

      {
        "content_id" => content_id,
        "expanded_links" =>
          {
            "taxons" => paths.map { |path| path_converter.call(path.reverse) },
          },
      }
    end
  end
end
