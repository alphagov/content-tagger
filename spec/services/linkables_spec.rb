require "rails_helper"

RSpec.describe Linkables do
  include ContentItemHelper
  include PublishingApiHelper

  let(:linkables) { Linkables.new }

  describe '.taxons' do
    before do
      publishing_api_has_content_items_for_linkables(
        [
          basic_content_item(
            'invalid 1',
            other_fields: {
              content_id: 'invalid-1',
              publication_state: 'live',
              details: {
                internal_name: nil,
              }
            }
          ),
          basic_content_item(
            'invalid 2',
            other_fields: {
              content_id: 'invalid-2',
              publication_state: 'live',
              details: {
                internal_name: '',
              }
            }
          ),
          basic_content_item(
            'valid 1',
            other_fields: {
              content_id: 'valid-1',
              publication_state: 'live',
              details: {
                internal_name: 'Valid-1!',
              }
            }
          ),
          basic_content_item(
            'valid 2',
            other_fields: {
              content_id: 'valid-2',
              publication_state: 'live',
              details: {
                internal_name: 'Valid-2!',
              }
            }
          ),
        ],
        document_type: 'taxon',
      )
    end

    it 'returns an array of hashes with only valid taxons' do
      expect(linkables.taxons).to eq(
        [%w(Valid-1! valid-1), %w(Valid-2! valid-2)]
      )
    end

    it 'filters out excluded IDs' do
      expect(linkables.taxons(exclude_ids: 'valid-2')).to eq(
        [%w(Valid-1! valid-1)]
      )
    end
  end

  describe ".topics" do
    it 'returns an array of hashes with title and content id pairs' do
      publishing_api_has_content_items_for_linkables(
        [
          basic_content_item(
            "Pension scheme administration",
            other_fields: {
              content_id: "e1d6b771-a692-4812-a4e7-7562214286ef",
              publication_state: 'live',
              base_path: "/topic/business-tax/pension-scheme-administration",
              details: {
                internal_name: "Business tax / Pension scheme administration",
              }
            }
          ),
          basic_content_item(
            '',
            other_fields: {
              content_id: "3535b8ad-7209-4c97-9dac-e25c25d9c27c",
              publication_state: 'live',
              base_path: "/topic/redirect",
              details: {
                internal_name: nil,
              }
            }
          )
        ],
        document_type: 'topic'
      )

      expected = {
        "Business tax" => [
          ["Business tax / Pension scheme administration", "e1d6b771-a692-4812-a4e7-7562214286ef"]
        ]
      }

      expect(linkables.topics).to eq expected
    end
  end

  describe ".organisations" do
    it "returns an array of arrays with title and content id pairs" do
      publishing_api_has_content_items_for_linkables(
        [
          basic_content_item(
            "Student Loans Company",
            other_fields: {
              content_id: "9a9111aa-1db8-4025-8dd2-e08ec3175e72",
              publication_state: 'live',
              base_path: "/government/organisations/student-loans-company",
              details: {
                internal_name: "Student Loans Company",
              }
            }
          )
        ],
        document_type: 'organisation'
      )

      expect(linkables.organisations).to eq [
        ["Student Loans Company", "9a9111aa-1db8-4025-8dd2-e08ec3175e72"]
      ]
    end
  end
end
