require 'rails_helper'

RSpec.describe AlphaTaxonomy::TaxonRenamer do
  describe "#run!" do
    let(:base_paths) do
      [
        { from: "/alpha-taxonomy/awesome-taxon", to: "/alpha-taxonomy/renamed-awesome-taxon" },
        { from: "/alpha-taxonomy/4-some-taxon", to: "/alpha-taxonomy/some-taxon" },
      ]
    end

    let(:lookup_hash) do
      {
        "/alpha-taxonomy/awesome-taxon" => "12fef5c0-c906-4889-926a-05fbb2a3742b",
        "/alpha-taxonomy/4-some-taxon"  => "7ff013ad-9338-4a70-b770-69bdc5399324",
      }
    end

    def test_payload(title, base_path)
      {
        base_path: base_path,
        format: 'taxon',
        title: title,
        publishing_app: 'collections-publisher',
        rendering_app: 'collections',
        public_updated_at: anything,
        locale: 'en',
        routes: [
          { path: base_path, type: "exact" },
        ]
      }
    end

    before do
      publishing_api_has_lookups(lookup_hash)
    end

    it "requests Publishing API to change title and base_path" do
      expect(Services.publishing_api).to receive(:publish)
        .with("12fef5c0-c906-4889-926a-05fbb2a3742b", "major")

      expect(Services.publishing_api).to receive(:publish)
        .with("7ff013ad-9338-4a70-b770-69bdc5399324", "major")

      expect(Services.publishing_api).to receive(:put_content)
        .with("12fef5c0-c906-4889-926a-05fbb2a3742b", test_payload('Renamed awesome taxon', "/alpha-taxonomy/renamed-awesome-taxon"))

      expect(Services.publishing_api).to receive(:put_content)
        .with("7ff013ad-9338-4a70-b770-69bdc5399324", test_payload('Some taxon', "/alpha-taxonomy/some-taxon"))

      AlphaTaxonomy::TaxonRenamer.new(base_paths: base_paths).run!
    end

    it 'is valid against the taxon schema' do
      expect(Services.publishing_api).to receive(:put_content)
        .with("12fef5c0-c906-4889-926a-05fbb2a3742b", be_valid_against_schema('taxon'))
        .once

      expect(Services.publishing_api).to receive(:publish)
        .with("12fef5c0-c906-4889-926a-05fbb2a3742b", "major")
        .once

      AlphaTaxonomy::TaxonRenamer.new(base_paths: [base_paths.first]).run!
    end
  end
end
