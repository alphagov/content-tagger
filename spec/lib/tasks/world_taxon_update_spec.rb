# frozen_string_literal: true

# require 'app/services/taxonomy/update_taxon/InvalidTaxonError'

RSpec.describe "Rake task worldwide:add_country_name_to_title", type: :task do
  include RakeTaskHelper

  let(:linked_item1) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/test/1",
      content_id: WORLD_ROOT_CONTENT_ID,
      title: "UK things in other countries",
      internal_name: "UK things in other countries"
    )
  end
  let(:linked_item2) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/test/2",
      content_id: "taxon2",
      title: "Living in Moe's tavern",
      internal_name: "Living in Moe's Tavern"
    )
  end
  let(:linked_item3) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/test/3",
      content_id: "taxon3",
      title: "Doing a thing",
      internal_name: "Doing a thing (GENERIC)"
    )
  end
  let(:linked_item4) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/test/4",
      content_id: "taxon4",
      title: "Tax, benefits, pensions and working abroad",
      internal_name: "Tax, benefits, pensions and working abroad (Betelgeuse)"
    )
  end

  let(:root_item) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/root",
      content_id: WORLD_ROOT_CONTENT_ID,
      title: "Stuff around the world",
      internal_name: "Stuff around the world"
    )
  end
  let(:parent_item) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/root/taxon_a",
      content_id: "id2",
      title: "UK help and services in Porpoise Spit",
      internal_name: "UK help and services in Porpoise Spit"
    )
  end
  let(:child_item1) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/root/taxon_1",
      content_id: "id3",
      title: "Coming to the UK (Porpoise Spit)",
      internal_name: "Coming to the UK (Porpoise Spit)"
    )
  end
  let(:child_item2) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/root/taxon_2",
      content_id: "id4",
      title: "Trade and invest (Porpoise Spit)",
      internal_name: "Trade and invest (Porpoise Spit)"
    )
  end

  let(:child_taxon1) do
    FactoryBot.build(:taxon, content_id: 'id3', title: "Coming to the UK from Porpoise Spit")
    # Taxonomy::Taxon.new(
    #   base_path: "/root/taxon_1",
    #   content_id: "id3",
    #   title: "Coming to the UK (Porpoise Spit)"
    #   )
  end
  let(:child_taxon2) do
    FactoryBot.build(:taxon, content_id: 'id4', title: "Trade and invest: Porpoise Spit")
    # Taxonomy::Taxon.new(
    #   base_path: "/root/taxon_2",
    #   content_id: "id4",
    #   title: "Trade and invest (Porpoise Spit)"
    #   )
  end

  let(:multi_level_taxons) do
    root_item << parent_item
    parent_item << child_item1 << child_item2

    root_item
  end

  describe "add_country_name_to_title" do
    before do
      allow_any_instance_of(Taxonomy::ExpandedTaxonomy).to receive_message_chain(:build, :child_expansion).and_return(multi_level_taxons)

      # stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/91b8ef20-74e7-4552-880c-50e6d73c2ff9")
      #   .to_return(status: 200, body: "", headers: {})

      # stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/id1")
      #   .to_return(status: 200, body: "", headers: {})
    end

    it "logs an error if the taxon is invalid" do
      allow(Taxonomy::BuildTaxon).to receive(:call).and_raise(Taxonomy::UpdateTaxon::InvalidTaxonError.new("Invalid taxon"))

      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/An error occurred while processing taxon/).to_stdout
    end

    it "logs an error if publishing taxons fails" do
      allow(Taxonomy::BulkPublishTaxon).to receive(:call).and_raise(GdsApi::HTTPConflict.new("Conflict error"))

      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/An error occurred while publishing taxons/).to_stdout
    end

    it "updates the taxon title correctly" do
      # allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: root_item.content_id).and_return(root_taxon)
      # allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: parent_item.content_id).and_return(parent_taxon)
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: child_item1.content_id).and_return(child_taxon1)
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: child_item2.content_id).and_return(child_taxon2)
      allow(Taxonomy::BulkPublishTaxon).to receive(:call).with(WORLD_ROOT_CONTENT_ID)
      allow(Taxonomy::UpdateTaxon).to receive(:call).with(taxon: child_taxon1)
      allow(Taxonomy::UpdateTaxon).to receive(:call).with(taxon: child_taxon2)


      rake("worldwide:add_country_name_to_title", "tmp/rake_log")

      child_taxon1.title = "Coming to the UK from Porpoise Spit"
      child_taxon2.title = "Trade and invest: Porpoise Spit"
      expect(Taxonomy::BulkPublishTaxon).to have_received(:call).with(WORLD_ROOT_CONTENT_ID)
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: child_taxon1)
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: child_taxon2)
    end

    it "logs when skipping taxons that already include the country name" do
      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/Skipping UK help and services in Porpoise Spit/).to_stdout
    end
  end

  describe "worldwide:remove_country_name_from_title" do
    before do
      allow_any_instance_of(Taxonomy::ExpandedTaxonomy).to receive_message_chain(:build, :child_expansion).and_return(multi_level_taxons)
      stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/91b8ef20-74e7-4552-880c-50e6d73c2ff9")
        .to_return(status: 200, body: "", headers: {})

      # stub_content_store_has_item("/", multi_level_taxons.to_json, draft: true)
    end

    it "reverts the taxon title correctly" do
      rake("worldwide:remove_country_name_from_title")

      expect(child_taxon1.title).to eq("Coming to the UK")
      expect(child_taxon2.title).to eq("Trade and invest")
    end

    it "logs an error if the taxon is invalid" do
      allow(Taxonomy::BuildTaxon).to receive(:call).and_raise(Taxonomy::UpdateTaxon::InvalidTaxonError.new("Invalid taxon"))

      expect { rake("worldwide:remove_country_name_from_title") }.to output(/An error occurred while processing taxon/).to_stdout
    end

    it "logs an error if publishing taxons fails" do
      allow(Taxonomy::BulkPublishTaxon).to receive(:call).and_raise(GdsApi::HTTPConflict.new("Conflict error"))

      expect { rake("worldwide:remove_country_name_from_title") }.to output(/An error occurred while publishing taxons/).to_stdout
    end
  end

  describe ".skip_tree_item?" do
    context "when the taxon is not a root, a generic or already includes the country name" do
      it "returns false" do
        FakeFS do
          FileUtils.mkdir_p("tmp")
          open("tmp/rake_log", "w") do |f|
            expect(described_class.send(:skip_tree_item?, f, linked_item4)).to be(false)
          end
        end
      end

      context "when the taxon is a root, a generic or already includes the country name" do
        it "returns true" do
          FakeFS do
            FileUtils.mkdir_p("tmp")
            open("tmp/rake_log", "w") do |f|
              expect(described_class.send(:skip_tree_item?, f, linked_item1)).to be(true)
              expect(described_class.send(:skip_tree_item?, f, linked_item2)).to be(true)
              expect(described_class.send(:skip_tree_item?, f, linked_item3)).to be(true)
            end
          end
        end
      end
    end
  end

  describe ".create_new_taxon_title" do
    it "correctly adds the country name to the title" do
      expect(create_new_taxon_title("Coming to the UK (Asgard)")).to eq(["adding - ...from COUNTRY_NAME", "Coming to the UK from Asgard"])
      expect(create_new_taxon_title("Trade and invest (Camberwick Green)")).to eq(["adding - ...: COUNTRY_NAME", "Trade and invest: Camberwick Green"])
      expect(create_new_taxon_title("Birth, death and marriage abroad (Twin Peaks)")).to eq(["adding - ...in COUNTRY_NAME", "Birth, death and marriage abroad in Twin Peaks"])
    end
  end
end
