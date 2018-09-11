require_relative("taxon_helper")
require 'rails_helper'

RSpec.describe Support::TaxonHelper do
  describe '#expanded_link_hash' do
    it 'has a correct helper' do
      result = Support::TaxonHelper.expanded_link_hash("a", [%w[b], %w[f e d c]])
      expected_hash = {
        "content_id" => "a",
        "expanded_links" => {
          "taxons" => [
            {
              "content_id" => "b"
            },
            {
              "content_id" => "c",
              "links" => {
                "parent_taxons" => [
                  {
                    "content_id" => "d",
                    "links" => {
                      "parent_taxons" => [
                        {
                          "content_id" => "e",
                          "links" => {
                            "root_taxon" => [
                              {
                                "content_id" => "f",
                              }
                            ]
                          },
                        }
                      ]
                    },
                  }
                ]
              },
            }
          ],
        },
      }
      expect(result).to eq(expected_hash)
    end
  end
end
