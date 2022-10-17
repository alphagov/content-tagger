RSpec.describe TaxonBasePathStructureCheck::Taxon, "#valid_base_path" do
  it "produces a base path for an imported-browse top level page" do
    klass = described_class.new(
      { "base_path" => "/imported-browse/sale-goods-services-data" },
      level_one_prefix: "business",
    )

    expect(klass.valid_base_path).to eq "/business/sale-goods-services-data"
  end

  it "produces a base path for an imported-browse page" do
    klass = described_class.new(
      { "base_path" => "/imported-browse/browse/driving/parking-public-transport-environment/environment-and-emissions" },
      level_one_prefix: "environment",
    )

    expect(klass.valid_base_path).to eq "/environment/driving-parking-public-transport-environment-environment-and-emissions"
  end

  it "produces a base path for an imported-topic top level page" do
    klass = described_class.new(
      { "base_path" => "/imported-topic/land-management" },
      level_one_prefix: "environment",
    )

    expect(klass.valid_base_path).to eq "/environment/land-management"
  end

  it "produces a base path for an imported-topic page" do
    klass = described_class.new(
      { "base_path" => "/imported-topic/topic/environmental-management/environmental-permits/application-forms" },
      level_one_prefix: "environment",
    )

    expect(klass.valid_base_path).to eq "/environment/environmental-management-environmental-permits-application-forms"
  end

  it "produces a base path for an imported-policies page" do
    klass = described_class.new(
      { "base_path" => "/imported-policies/export-controls" },
      level_one_prefix: "business",
    )

    expect(klass.valid_base_path).to eq "/business/export-controls"
  end
end
