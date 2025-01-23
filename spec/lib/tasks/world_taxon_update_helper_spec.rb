# frozen_string_literal: true

require "world_taxon_update_helper"

RSpec.describe WorldTaxonUpdateHelper do
  let(:root_item) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/root",
      content_id: WORLD_ROOT_CONTENT_ID,
      title: "Stuff around the world",
      internal_name: "Stuff around the world",
    )
  end
  let(:parent_item_uk_help) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/root/taxon_a",
      content_id: "id2",
      title: "UK help and services in Porpoise Spit",
      internal_name: "UK help and services in Porpoise Spit",
    )
  end
  let(:child_item_coming_to) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/root/taxon_1",
      content_id: "id3",
      title: "Coming to the UK",
      internal_name: "Coming to the UK (Porpoise Spit)",
    )
  end
  let(:child_item_trade_invest) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/root/taxon_2",
      content_id: "id4",
      title: "Trade and invest",
      internal_name: "Trade and invest (Porpoise Spit)",
    )
  end
  let(:child_item_birth_death) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/root/taxon_3",
      content_id: "id5",
      title: "Birth, death and marriage abroad",
      internal_name: "Birth, death and marriage abroad (Porpoise Spit)",
    )
  end
  let(:multi_level_linked_items) do
    root_item << parent_item_uk_help
    parent_item_uk_help << child_item_coming_to << child_item_trade_invest << child_item_birth_death

    root_item
  end

  let(:log_file) { File.open("tmp/logfile.log", "w") }

  before do
    allow(Taxonomy::BulkPublishTaxon).to receive(:call)
  end

  def allow_item_as_expanded_taxonomy_double(item)
    item_double = instance_double(Taxonomy::ExpandedTaxonomy, child_expansion: item)
    allow(item_double).to receive(:build).and_return(item_double)
    allow(Taxonomy::ExpandedTaxonomy).to receive(:new).and_return(item_double)
  end

  describe "add_country_name_to_title" do
    it "logs to stderr and doesn't continue processing taxons if BuildTaxon fails" do
      allow_item_as_expanded_taxonomy_double(multi_level_linked_items)
      allow(Taxonomy::BuildTaxon).to receive(:call).and_raise(Taxonomy::BuildTaxon::DocumentTypeError.new("Document type error"))

      expect(Taxonomy::BuildTaxon).to receive(:call).once
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)
      expect(Taxonomy::BulkPublishTaxon).not_to receive(:call)
      expect { described_class.new(log_file).add_country_names }.to output(/An error occurred while processing taxon Coming to the UK \(Porpoise Spit\)/).to_stderr
    end

    it "logs an error to stderr if BulkPublishFails" do
      allow_item_as_expanded_taxonomy_double(multi_level_linked_items)
      allow(Taxonomy::BuildTaxon).to receive(:call)
      allow(Taxonomy::UpdateTaxon).to receive(:call)
      allow(Taxonomy::BulkPublishTaxon).to receive(:call).and_raise(GdsApi::HTTPConflict.new("Conflict error"))

      expect { described_class.new(log_file).add_country_names }.to output(/An error occurred while publishing taxons/).to_stderr
    end

    it "correctly updates the taxon title, adding the corresponding words etc before the country name" do
      child_taxon_birth_death = FactoryBot.build(:taxon, content_id: "id5", title: "Birth, death and marriage abroad")
      child_taxon_trade_invest = FactoryBot.build(:taxon, content_id: "id4", title: "Trade and invest")
      child_taxon_coming_to = FactoryBot.build(:taxon, content_id: "id3", title: "Coming to the UK")

      allow_item_as_expanded_taxonomy_double(multi_level_linked_items)
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: child_item_coming_to.content_id).and_return(child_taxon_coming_to)
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: child_item_trade_invest.content_id).and_return(child_taxon_trade_invest)
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: child_item_birth_death.content_id).and_return(child_taxon_birth_death)
      allow(Taxonomy::UpdateTaxon).to receive(:call)

      described_class.new(log_file).add_country_names

      # Tests all three title change possibilities
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: having_attributes(content_id: child_taxon_coming_to.content_id, title: "Coming to the UK from Porpoise Spit"))
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: having_attributes(content_id: child_taxon_trade_invest.content_id, title: "Trade and invest: Porpoise Spit"))
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: having_attributes(content_id: child_taxon_birth_death.content_id, title: "Birth, death and marriage abroad in Porpoise Spit"))
    end
  end

  describe "skip_tree_item?" do
    let(:linked_item_generic) do
      Taxonomy::LinkedContentItem.new(
        base_path: "/test/3",
        content_id: "taxon3",
        title: "Doing a thing",
        internal_name: "Doing a thing (GENERIC)",
      )
    end
    let(:linked_item_travelling_to) do
      Taxonomy::LinkedContentItem.new(
        base_path: "/root/1",
        content_id: "id10",
        title: "Travelling to Porpoise Spit",
        internal_name: "Travelling to Porpoise Spit",
      )
    end
    let(:linked_item_living_in) do
      Taxonomy::LinkedContentItem.new(
        base_path: "/test/2",
        content_id: "taxon2",
        title: "Living in Moe's tavern",
        internal_name: "Living in Moe's Tavern",
      )
    end

    it "skips the root taxon which has the WORLD_ROOT_CONTENT_ID" do
      allow_item_as_expanded_taxonomy_double(root_item)
      expect(Taxonomy::BuildTaxon).not_to receive(:call)
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)
      expect(described_class.new(log_file)).not_to receive(:create_title_adding_country_name).with(root_item.internal_name)

      expect { described_class.new(log_file).add_country_names }.to output(/Skipping world root taxon/).to_stdout
    end

    it "skips taxons with internal names which start with 'UK help and services '" do
      allow_item_as_expanded_taxonomy_double(parent_item_uk_help)
      expect(Taxonomy::BuildTaxon).not_to receive(:call)
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)
      expect(described_class.new(log_file)).not_to receive(:create_title_adding_country_name).with(parent_item_uk_help.internal_name)

      expect { described_class.new(log_file).add_country_names }.to output(/Skipping UK help and services in Porpoise Spit/).to_stdout
    end

    it "skips taxons with internal names which start with 'Living in '" do
      allow_item_as_expanded_taxonomy_double(linked_item_living_in)
      expect(Taxonomy::BuildTaxon).not_to receive(:call)
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)
      expect(described_class.new(log_file)).not_to receive(:create_title_adding_country_name).with(linked_item_living_in.internal_name)

      expect { described_class.new(log_file).add_country_names }.to output(/Skipping Living in Moe's Tavern/).to_stdout
    end

    it "skips taxons with internal names which start with 'Travelling to '" do
      allow_item_as_expanded_taxonomy_double(linked_item_travelling_to)
      expect(Taxonomy::BuildTaxon).not_to receive(:call)
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)
      expect(described_class.new(log_file)).not_to receive(:create_title_adding_country_name).with(linked_item_travelling_to.internal_name)

      expect { described_class.new(log_file).add_country_names }.to output(/Skipping Travelling to Porpoise Spit/).to_stdout
    end

    it "skips taxons with internal names that include '(GENERIC)'" do
      allow_item_as_expanded_taxonomy_double(linked_item_generic)
      expect(Taxonomy::BuildTaxon).not_to receive(:call)
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)
      expect(described_class.new(log_file)).not_to receive(:create_title_adding_country_name).with(linked_item_generic.internal_name)

      expect { described_class.new(log_file).add_country_names }.to output(/Skipping Doing a thing \(GENERIC\)/).to_stdout
    end
  end

  describe "remove_country_name_from_title" do
    # Set up the already processed taxons we will need to revert (e.g. titles including the COUNTRY_NAME)
    let(:retitled_child_item_coming_to) do
      Taxonomy::LinkedContentItem.new(
        base_path: "/root/taxon_1",
        content_id: "id3",
        title: "Coming to the UK from Porpoise Spit",
        internal_name: "Coming to the UK (Porpoise Spit)",
      )
    end
    let(:retitled_child_item_trade_invest) do
      Taxonomy::LinkedContentItem.new(
        base_path: "/root/taxon_2",
        content_id: "id4",
        title: "Trade and invest: Porpoise Spit",
        internal_name: "Trade and invest (Porpoise Spit)",
      )
    end
    let(:retitled_child_item_birth_death) do
      Taxonomy::LinkedContentItem.new(
        base_path: "/root/taxon_3",
        content_id: "id5",
        title: "Birth, death and marriage abroad in Porpoise Spit",
        internal_name: "Birth, death and marriage abroad (Porpoise Spit)",
      )
    end
    let(:retitled_multi_level_linked_items) do
      root_item << parent_item_uk_help
      parent_item_uk_help << retitled_child_item_coming_to << retitled_child_item_trade_invest << retitled_child_item_birth_death

      root_item
    end

    it "logs to stderr and doesn't continue processing taxons if BuildTaxon fails" do
      allow_item_as_expanded_taxonomy_double(multi_level_linked_items)
      allow(Taxonomy::BuildTaxon).to receive(:call).and_raise(Taxonomy::BuildTaxon::DocumentTypeError.new("Document type error"))

      expect(Taxonomy::BuildTaxon).to receive(:call).once
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)
      expect(Taxonomy::BulkPublishTaxon).not_to receive(:call)
      expect { described_class.new(log_file).add_country_names }.to output(/An error occurred while processing taxon Coming to the UK \(Porpoise Spit\)/).to_stderr
    end

    it "logs an error to stderr if BulkPublishFails" do
      allow_item_as_expanded_taxonomy_double(multi_level_linked_items)
      allow(Taxonomy::BuildTaxon).to receive(:call)
      allow(Taxonomy::UpdateTaxon).to receive(:call)
      allow(Taxonomy::BulkPublishTaxon).to receive(:call).and_raise(GdsApi::HTTPConflict.new("Conflict error"))

      expect { described_class.new(log_file).add_country_names }.to output(/An error occurred while publishing taxons/).to_stderr
    end

    it "correctly updates the taxon title, removing the country name and any added words etc" do
      retitled_child_taxon_birth_death = FactoryBot.build(:taxon, content_id: "id5", title: "Birth, death and marriage abroad in Porpoise Spit")
      retitled_child_taxon_trade_invest = FactoryBot.build(:taxon, content_id: "id4", title: "Trade and invest: Porpoise Spit")
      retitled_child_taxon_coming_to = FactoryBot.build(:taxon, content_id: "id3", title: "Coming to the UK from Porpoise Spit")

      allow_item_as_expanded_taxonomy_double(retitled_multi_level_linked_items)
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: retitled_child_item_coming_to.content_id).and_return(retitled_child_taxon_coming_to)
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: retitled_child_item_trade_invest.content_id).and_return(retitled_child_taxon_trade_invest)
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: retitled_child_item_birth_death.content_id).and_return(retitled_child_taxon_birth_death)
      allow(Taxonomy::UpdateTaxon).to receive(:call)

      described_class.new(log_file).remove_country_names

      # Tests all three title change possibilities
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: having_attributes(content_id: retitled_child_item_coming_to.content_id, title: "Coming to the UK"))
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: having_attributes(content_id: retitled_child_item_trade_invest.content_id, title: "Trade and invest"))
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: having_attributes(content_id: retitled_child_item_birth_death.content_id, title: "Birth, death and marriage abroad"))
    end
  end
end
