RSpec.describe Taxon do
  describe "validations" do
    it "is not valid without a title" do
      taxon = described_class.new
      expect(taxon).not_to be_valid
      expect(taxon.errors.attribute_names).to include(:title)
    end

    it "is not valid without a base path" do
      taxon = described_class.new(base_path: "")

      expect(taxon).not_to be_valid
      expect(taxon.errors.attribute_names).to include(:base_path)
    end

    it "is not valid when the base path prefix does not match the parent prefix" do
      parent_taxon = FactoryBot.build(:taxon, base_path: "/level-one/level-two")
      allow(Taxonomy::BuildTaxon).to receive(:call).and_return(parent_taxon)

      child_taxon = FactoryBot.build(
        :taxon,
        base_path: "/foo/level-two",
        parent_content_id: parent_taxon.content_id,
      )

      expect(child_taxon).not_to be_valid
      expect(child_taxon.errors[:base_path]).to include("must start with /level-one")
    end
  end

  context "when internal_name is not set" do
    it "uses the title value" do
      taxon = described_class.new(title: "I Title")

      expect(taxon.internal_name).to eql(taxon.title)
    end
  end

  context "without notes_for_editors set" do
    it "returns an empty string to comply with the schema definition" do
      taxon = described_class.new

      expect(taxon.notes_for_editors).to eq("")
    end
  end

  context "without url_override set" do
    it "returns an empty string to comply with the schema definition" do
      taxon = described_class.new

      expect(taxon.url_override).to eq("")
    end
  end

  context "with url_override set" do
    it "must have the correct format" do
      valid_taxon = described_class.new(
        title: "Title",
        description: "Description",
        base_path: "/education",
        url_override: "/guidance/something/education-is-fun",
      )

      invalid_taxon = described_class.new(
        title: "Title",
        description: "Description",
        base_path: "/education",
        url_override: "education-is-b@d!",
      )

      expect(valid_taxon).to be_valid
      expect(invalid_taxon).not_to be_valid
      expect(invalid_taxon.errors[:url_override]).to include(
        "must be in the format '/prefix/slug' or '/slug'",
      )
    end
  end

  it "must have a base path with at most two segments" do
    level_one_taxon = described_class.new(
      title: "Title",
      description: "Description",
      base_path: "/education",
    )

    level_two_taxon = described_class.new(
      title: "Title",
      description: "Description",
      base_path: "/education/ab01-cd02",
    )

    invalid_taxon = described_class.new(
      title: "Title",
      description: "Description",
      base_path: "/education/foo/bar",
    )

    aggregate_failures do
      expect(level_one_taxon).to be_valid
      expect(level_two_taxon).to be_valid
      expect(invalid_taxon).not_to be_valid
      expect(invalid_taxon.errors[:base_path]).to include(
        "must be in the format '/highest-level-taxon-name/taxon-name'",
      )
    end
  end

  describe "#base_path=" do
    it "separates the prefix and slug values" do
      taxon = described_class.new(
        base_path: "/childcare-parenting/childcare-and-early-years",
      )

      expect(taxon.path_prefix).to eq "childcare-parenting"
      expect(taxon.path_slug).to eq "childcare-and-early-years"
    end
  end

  describe "#base_path" do
    it "returns the base_path for root taxons" do
      expect(described_class.new(
        base_path: "/childcare-parenting",
      ).base_path).to eq "/childcare-parenting"
    end

    it "returns the base_path for child taxons" do
      expect(described_class.new(
        base_path: "/childcare-parenting/childcare-and-early-years",
      ).base_path).to eq "/childcare-parenting/childcare-and-early-years"
    end
  end

  describe "#visible_to_departmental_editors" do
    it "defaults to false if it's not set" do
      taxon = described_class.new
      expect(taxon.visible_to_departmental_editors).to be false
    end

    it "can be set through the initializer by value" do
      taxon = described_class.new(visible_to_departmental_editors: true)
      expect(taxon.visible_to_departmental_editors).to be true
    end

    it "can be set through the initializer by string" do
      taxon = described_class.new(visible_to_departmental_editors: "true")
      expect(taxon.visible_to_departmental_editors).to be true
    end
  end

  describe "publishing history of taxon" do
    let(:taxon) do
      state_history = {
        "4" => "superseded",
        "5" => "superseded",
        "2" => "superseded",
        "7" => "draft",
        "3" => "superseded",
        "6" => "published",
        "1" => "superseded",
      }

      described_class.new(
        visible_to_departmental_editors: "true",
        state_history:,
        publication_state: "published",
      )
    end

    it "orders state history" do
      expected_order = %w[
        superseded
        superseded
        superseded
        superseded
        superseded
        published
        draft
      ]

      expect(taxon.ordered_publication_state_history).to eq(expected_order)
    end

    it "gets the lastest two publication states" do
      expected_states = %w[
        published
        draft
      ]

      expect(taxon.lastest_two_publication_states).to eq(expected_states)
    end

    describe "#draft_and_published_editions_exist?" do
      it "returns true if a draft taxon has been previously published" do
        expect(taxon.draft_and_published_editions_exist?).to be(true)
      end

      it "returns false the taxon is published" do
        state_history = {
          "4" => "superseded",
          "5" => "superseded",
          "2" => "superseded",
          "3" => "superseded",
          "6" => "published",
          "1" => "superseded",
        }

        taxon = described_class.new(
          visible_to_departmental_editors: "true",
          state_history:,
          publication_state: "published",
        )
        expect(taxon.draft_and_published_editions_exist?).to be(false)
      end

      it "returns false if a taxon has never been published" do
        state_history = {
          "1" => "draft",
        }

        taxon = described_class.new(
          visible_to_departmental_editors: "true",
          state_history:,
          publication_state: "draft",
        )
        expect(taxon.draft_and_published_editions_exist?).to be(false)
      end
    end
  end
end
