require 'rails_helper'

module DataExport
  RSpec.describe ContentExport do
    describe '#get_content' do
      it 'returns empty hash if there is no content for the base path' do
        expect(Services.content_store).to receive(:content_item).with('/base_path').and_raise GdsApi::ContentStore::ItemNotFound.new(404)
        expect(ContentExport.new.get_content('/base_path')).to eq({})
      end
      it 'returns simple content' do
        expect(Services.content_store).to receive(:content_item).with('/base_path').and_return content_no_taxon
        expect(ContentExport.new.get_content('/base_path', base_fields: %w[base_path content_id]))
          .to eq("base_path" => "/base_path", "content_id" => "d282d35a-2bd2-4e14-a7a6-a04e6b10520f")
      end
      it 'returns taxons' do
        expect(Services.content_store).to receive(:content_item).with('/base_path').and_return content_with_taxons
        expect(ContentExport.new.get_content('/base_path', taxon_fields: %w[content_id])['taxons'])
          .to eq([{ "content_id" => "237b2e72-c465-42fe-9293-8b6af21713c0" },
                  { "content_id" => "8da62d85-47c0-42df-94c4-eaaeac329671" }])
      end
      it 'returns the primary publishing organistations' do
        expect(Services.content_store).to receive(:content_item).with('/base_path').and_return content_with_ppo
        expect(ContentExport.new.get_content('/base_path', ppo_fields: %w[title])['primary_publishing_organisation'])
          .to eq("title" => "title1")
      end

      def content_with_taxons
        {
          "base_path" => "/base_path",
          "content_id" => "d282d35a-2bd2-4e14-a7a6-a04e6b10520f",
          "links" => {
            "taxons" => [{ "content_id" => "237b2e72-c465-42fe-9293-8b6af21713c0" },
                         { "content_id" => "8da62d85-47c0-42df-94c4-eaaeac329671" }]
          }
        }
      end

      def content_with_ppo
        {
          "base_path" => "/base_path",
          "content_id" => "d282d35a-2bd2-4e14-a7a6-a04e6b10520f",
          "links" => {
            "primary_publishing_organisation" => [
              { "title" => "title1" }
            ]
          },
        }
      end

      def content_no_taxon
        {
          "base_path" => "/base_path",
          "content_id" => "d282d35a-2bd2-4e14-a7a6-a04e6b10520f",
          "links" => {
          }
        }
      end
    end

    describe '#content_links_enum' do
      it 'returns an empty enumerator' do
        expect(Services.rummager).to receive(:search).and_return empty_content
        expect(ContentExport.new.content_links_enum).to be_a(Enumerator)
        expect(ContentExport.new.content_links_enum.to_a).to eq([])
      end
      it 'returns two windows' do
        expect(Services.rummager).to receive(:search).with(hash_including(start: 0)).and_return two_content_items
        expect(Services.rummager).to receive(:search).with(hash_including(start: 2)).and_return one_content_item
        expect(ContentExport.new.content_links_enum(2).to_a).to eq(["/first/path", "/second/path", "/one/path"])
      end
      it 'returns one window - edge case' do
        expect(Services.rummager).to receive(:search).with(hash_including(start: 0)).and_return two_content_items
        expect(Services.rummager).to receive(:search).with(hash_including(start: 2)).and_return empty_content
        expect(ContentExport.new.content_links_enum(2).to_a).to eq(["/first/path", "/second/path"])
      end
    end

    def two_content_items
      {
        "results" => [
          {
            "link" => "/first/path",
          },
          {
            "link" => "/second/path",
          },
        ]
      }
    end

    def one_content_item
      {
        "results" => [
          {
            "link" => "/one/path",
          }
        ]
      }
    end

    def empty_content
      {
        "results" => []
      }
    end
  end
end
