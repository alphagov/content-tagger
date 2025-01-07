# frozen_string_literal: true

RSpec.describe "Rake task worldwide", type: :task do
  include RakeTaskHelper

  # TODO: Do we need to set ALL of these properties??
  # linked_item 1 - 4 are only used in test for skip_tree_item
  let(:linked_item_root) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/test/",
      content_id: WORLD_ROOT_CONTENT_ID,
      title: "UK things in other countries",
      internal_name: "UK things in other countries",
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
  let(:linked_item_generic) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/test/3",
      content_id: "taxon3",
      title: "Doing a thing",
      internal_name: "Doing a thing (GENERIC)",
    )
  end
  let(:linked_item_tax_benefits) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/test/4",
      content_id: "taxon4",
      title: "Tax, benefits, pensions and working abroad",
      internal_name: "Tax, benefits, pensions and working abroad (Betelgeuse)",
    )
  end

  let(:root_item) do
    Taxonomy::LinkedContentItem.new(
      base_path: "/root",
      content_id: WORLD_ROOT_CONTENT_ID,
      title: "Stuff around the world",
      internal_name: "Stuff around the world",
    )
  end
  let(:parent_item) do
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
  let(:multi_level_taxons) do
    root_item << parent_item
    parent_item << child_item_coming_to << child_item_trade_invest << child_item_birth_death

    root_item
  end

  let(:child_taxon_coming_to) do
    FactoryBot.build(:taxon, content_id: "id3", title: "Coming to the UK")
  end
  let(:child_taxon_trade_invest) do
    FactoryBot.build(:taxon, content_id: "id4", title: "Trade and invest")
  end
  let(:child_taxon_birth_death) do
    FactoryBot.build(:taxon, content_id: "id5", title: "Birth, death and marriage abroad")
  end

  def allow_item_double(item)
    child_double = instance_double(Taxonomy::ExpandedTaxonomy, child_expansion: item)
    item_double = instance_double(Taxonomy::ExpandedTaxonomy, build: child_double)
    allow(Taxonomy::ExpandedTaxonomy).to receive(:new).and_return(item_double)
  end

  describe "add_country_name_to_title" do
    before do
      allow_item_double(multi_level_taxons)
      allow(Taxonomy::BulkPublishTaxon).to receive(:call)
    end

    it "logs an error to stderr if the taxon is invalid" do
      allow(Taxonomy::BuildTaxon).to receive(:call).and_raise(Taxonomy::UpdateTaxon::InvalidTaxonError.new("Invalid taxon"))

      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/An error occurred while processing taxon/).to_stderr
    end

    it "logs an error to stderr if BulkPublishTaxon fails" do
      allow(Taxonomy::BuildTaxon).to receive(:call).and_return(child_taxon_coming_to)
      allow(Taxonomy::UpdateTaxon).to receive(:call)
      allow(Taxonomy::BulkPublishTaxon).to receive(:call).and_raise(GdsApi::HTTPConflict.new("Conflict error"))

      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/An error occurred while publishing taxons/).to_stderr
    end

    it "logs an error to stderr if an unexpected error is raised" do
      allow(Taxonomy::ExpandedTaxonomy).to receive(:new).and_raise(StandardError.new("An unexpected error occurred"))

      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/An unexpected error occurred/).to_stderr
    end

    it "updates the taxon title correctly" do
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: child_item_coming_to.content_id).and_return(child_taxon_coming_to)
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: child_item_trade_invest.content_id).and_return(child_taxon_trade_invest)
      allow(Taxonomy::BuildTaxon).to receive(:call).with(content_id: child_item_birth_death.content_id).and_return(child_taxon_birth_death)
      allow(Taxonomy::BulkPublishTaxon).to receive(:call)
      allow(Taxonomy::UpdateTaxon).to receive(:call)

      rake("worldwide:add_country_name_to_title", "tmp/rake_log")

      # Tests all three title change possibilities
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: having_attributes(content_id: child_taxon_coming_to.content_id, title: "Coming to the UK from Porpoise Spit"))
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: having_attributes(content_id: child_taxon_trade_invest.content_id, title: "Trade and invest: Porpoise Spit"))
      expect(Taxonomy::UpdateTaxon).to have_received(:call).with(taxon: having_attributes(content_id: child_taxon_birth_death.content_id, title: "Birth, death and marriage abroad in Porpoise Spit"))
    end

    it "skips the root taxon which has the WORLD_ROOT_CONTENT_ID" do
      # TODO: Replace call to LinkedContentItem constructor with a factory? - only need content_id?
      # TODO: This doesn't work: item = FactoryBot.build(:linked_content_item, content_id: WORLD_ROOT_CONTENT_ID)
      item = Taxonomy::LinkedContentItem.new(
        base_path: "/root",
        content_id: WORLD_ROOT_CONTENT_ID,
        title: "Some title",
        internal_name: "Some name",
      )
      allow_item_double(item)
      expect(Taxonomy::BuildTaxon).not_to receive(:call)
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)
      # TODO: Do we also need to test that create_new_taxon_title is not called?

      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/Skipping world root taxon/).to_stdout
    end

    it "skips taxons with internal names which start with 'UK help and services '" do
      item = Taxonomy::LinkedContentItem.new(
        base_path: "/root/1",
        content_id: "id10",
        title: "Some title",
        internal_name: "UK help and services in Porpoise Spit",
      )
      allow_item_double(item)
      expect(Taxonomy::BuildTaxon).not_to receive(:call)
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)

      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/Skipping UK help and services in Porpoise Spit/).to_stdout
    end

    it "skips taxons with internal names which start with 'Living in '" do
      item = Taxonomy::LinkedContentItem.new(
        base_path: "/root/1",
        content_id: "id10",
        title: "Some title",
        internal_name: "Living in Porpoise Spit",
      )
      allow_item_double(item)
      expect(Taxonomy::BuildTaxon).not_to receive(:call)
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)

      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/Skipping Living in Porpoise Spit/).to_stdout
    end

    it "skips taxons with internal names which start with 'Travelling to '" do
      item = Taxonomy::LinkedContentItem.new(
        base_path: "/root/1",
        content_id: "id10",
        title: "Some title",
        internal_name: "Travelling to Porpoise Spit",
      )
      allow_item_double(item)
      expect(Taxonomy::BuildTaxon).not_to receive(:call)
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)

      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/Skipping Travelling to Porpoise Spit/).to_stdout
    end

    it "skips taxons with internal names that include '(GENERIC)'" do
      item = Taxonomy::LinkedContentItem.new(
        base_path: "/root/1",
        content_id: "id10",
        title: "Some title",
        internal_name: "name (GENERIC)",
      )
      allow_item_double(item)
      expect(Taxonomy::BuildTaxon).not_to receive(:call)
      expect(Taxonomy::UpdateTaxon).not_to receive(:call)

      expect { rake("worldwide:add_country_name_to_title", "tmp/rake_log") }.to output(/Skipping name \(GENERIC\)/).to_stdout
    end
  end

  # TODO: describe "worldwide:remove_country_name_from_title" do
  # TODO: test it "reverts the taxon title correctly" do
  # Set up the already processed taxons we will need to revert (e.g. titles including the COUNTRY_NAME) in a describe before block if necessary
  #   TODO: Complete this with the reverse of above - need new LinkedContentItems and Taxons to test the title reversal?

  # TODO: Needed? Isn't this all tested sufficiently above? Do these even make sense??
  describe ".skip_tree_item?" do
    it "returns false when the taxon is not a root, a generic or already includes the country name" do
      # log_file = File.new('test_file', 'w')
      log_file_mock = instance_double(File)

      expect(described_class.send(:skip_tree_item?, log_file_mock, linked_item_tax_benefits)).to be(false)
    end

    it "returns true when the taxon is a root, a generic or already includes the country name" do
      # Need to find a way to mock this
      log_file = File.new("test_file", "w")

      expect(described_class.send(:skip_tree_item?, log_file, linked_item_root)).to be(true)
      expect(described_class.send(:skip_tree_item?, log_file, linked_item_living_in)).to be(true)
      expect(described_class.send(:skip_tree_item?, log_file, linked_item_generic)).to be(true)
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
