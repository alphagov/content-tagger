module LegacyTaxonomy
  class TaxonomyPublisher
    attr_reader :root_taxon

    def initialize(root_taxon)
      @root_taxon = root_taxon
    end

    def commit
      create_remote_taxon(root_taxon)
      commit_tree(root_taxon)
    end

  private

    def commit_tree(taxon)
      taxon.child_taxons.each do |sub_taxon|
        create_remote_taxon(sub_taxon, taxon)
        sub_taxon.tagged_pages.each do |taggable|
          tag_content(taggable, sub_taxon)
        end
        commit_tree(sub_taxon)
      end
    end

    def create_remote_taxon(taxon, parent_taxon = nil)
      puts "#{taxon.title} => #{taxon.base_path}"
      Client::PublishingApi.put_content(taxon.content_id, taxon_for_publishing_api(taxon))
      Client::PublishingApi.publish(taxon.content_id)

      return unless parent_taxon # rubocop
      Client::PublishingApi.patch_links(taxon.content_id, links: { parent_taxons: [parent_taxon.content_id] })
    end

    def tag_content(taggable, taxon)
      puts " - Tagging #{taggable['link']}"

      links = Client::PublishingApi.get_links(taggable['content_id'])
      previous_version = links['version'] || 0
      taxons = links.dig('links', 'taxons') || []
      taxons << taxon.content_id
      Client::PublishingApi.patch_links(taggable['content_id'], links: { taxons: taxons.uniq }, previous_version: previous_version)
    rescue GdsApi::HTTPNotFound
      puts "404 Taggable Not Found"
    end

    def taxon_for_publishing_api(taxon)
      taxon_attrs = taxon.hash_for_publishing_api
      taxon_ = Taxon.new(taxon_attrs)
      Taxonomy::BuildTaxonPayload.call(taxon: taxon_)
    end
  end
end
