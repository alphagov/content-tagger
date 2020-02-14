require "rails_helper"

RSpec.describe Taxonomy::SaveTaxonVersion, ".call" do
  it "saves a new version when the taxon is new" do
    taxon = Taxon.new(
      base_path: "/business",
      title: "Business",
      internal_name: "Business [internal]",
      description: "Business as usual",
      phase: "beta",
    )

    stub_publishing_api_does_not_have_item(taxon.content_id)

    described_class.call(taxon, "A new taxon")

    expect(Version.count).to eq(1)
    expect(Version.last).to have_attributes(
      content_id: taxon.content_id,
      number: 1,
      note: "A new taxon",
      object_changes: [
        ["+", "associated_taxons", nil],
        ["+", "base_path", "/business"],
        ["+", "description", "Business as usual"],
        ["+", "internal_name", "Business [internal]"],
        ["+", "notes_for_editors", ""],
        ["+", "parent_content_id", nil],
        ["+", "phase", "beta"],
        ["+", "title", "Business"],
      ],
    )
  end

  it "saves the change between old and new when the draft taxon is updated" do
    content_id = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"

    previous_fields = {
      content_id: content_id,
      title: "Tourism",
      description: "Send me a postcard",
      base_path: "/tourism",
      publication_state: "draft",
      document_type: "taxon",
      details: {
        internal_name: "Tourism [internal]",
        notes_for_editors: "",
      },
    }

    current_taxon = Taxon.new(
      content_id: content_id,
      base_path: "/business/tourism",
      title: "Tourism",
      internal_name: "Tourism [internal]",
      description: "Send me a postcard",
      parent_content_id: "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
    )

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/#{content_id}")
      .to_return(body: previous_fields.to_json)
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/#{content_id}")
      .to_return(body: {
        expanded_links: {
          associated_taxons: [
            { content_id: "mmmmmmmm-mmmm-mmmm-mmmm-mmmmmmmmmmmm" },
          ],
        },
      }.to_json)

    described_class.call(current_taxon, "An update note")

    expect(Version.count).to eq(1)
    expect(Version.last).to have_attributes(
      content_id: content_id,
      note: "An update note",
      object_changes: [
        ["~", "associated_taxons", %w[mmmmmmmm-mmmm-mmmm-mmmm-mmmmmmmmmmmm], nil],
        ["~", "base_path", "/tourism", "/business/tourism"],
        ["~", "parent_content_id", nil, "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"],
      ],
    )
  end

  it "does not saves a change when the old and new are the same" do
    content_id = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"

    previous_fields = {
      content_id: content_id,
      title: "Business Tourism",
      description: "Send me a postcard",
      base_path: "/business/tourism",
      publication_state: "draft",
      document_type: "taxon",
      details: {
        internal_name: "Business Tourism [internal]",
        notes_for_editors: "",
      },
    }

    current_taxon = Taxon.new(
      content_id: content_id,
      base_path: "/business/tourism",
      title: "Business Tourism",
      internal_name: "Business Tourism [internal]",
      description: "Send me a postcard",
    )

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/#{content_id}")
      .to_return(body: previous_fields.to_json)
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/#{content_id}")
      .to_return(body: {}.to_json)

    described_class.call(current_taxon, "")

    expect(Version.count).to eq(0)
  end

  it "saves a restore event when the taxon is restored" do
    content_id = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"

    previous_fields = {
      content_id: content_id,
      title: "Business",
      description: "Business as usual",
      base_path: "/business",
      publication_state: "unpublished",
      document_type: "taxon",
      details: {
        internal_name: "Business [internal]",
        notes_for_editors: "",
      },
    }

    current_taxon = Taxon.new(
      content_id: content_id,
      base_path: "/business",
      title: "Business",
      internal_name: "Business [internal]",
      description: "Business as usual",
    )

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/#{content_id}")
      .to_return(body: previous_fields.to_json)
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/expanded-links/#{content_id}")
      .to_return(body: {}.to_json)

    described_class.call(current_taxon, "Restoring a taxon")

    expect(Version.count).to eq(1)
    expect(Version.last).to have_attributes(
      content_id: content_id,
      note: "Restoring a taxon",
      object_changes: [],
    )
  end
end
