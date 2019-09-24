require "rails_helper"

module BulkTagging
  RSpec.describe BuildTagMapping do
    let(:taxon) { build(:taxon) }
    let(:build_tag_mapping) do
      described_class.new(taxon: taxon, content_base_path: "/content-base-path")
    end
    let(:tag_mapping) { build_tag_mapping.call }

    it "builds a TagMapping record" do
      expect(tag_mapping).to be_a(TagMapping)
    end

    it "assigns the content base path" do
      expect(tag_mapping.content_base_path).to eq("/content-base-path")
    end

    it "assigns the taxon title to link_title" do
      expect(tag_mapping.link_title).to eq(taxon.title)
    end

    it "assigns the taxon content id to link_content_id" do
      expect(tag_mapping.link_content_id).to eq(taxon.content_id)
    end

    it "assigns the taxon link type to link_type" do
      expect(tag_mapping.link_type).to eq(taxon.link_type)
    end

    it "gives it an initial state" do
      expect(tag_mapping.state).to eq("ready_to_tag")
    end
  end
end
