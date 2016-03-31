require 'rails_helper'

RSpec.describe AlphaTaxonomy::TaxonRenamer do
  describe "#run!" do
    context "given some taxon base paths might require change" do
      let(:base_paths) do
        [
          { from: "/alpha-taxonomy/awesome-taxon", to: "/alpha-taxonomy/renamed-awesome-taxon" },
          { from: "/alpha-taxonomy/4-some-taxon", to: "/alpha-taxonomy/some-taxon" },
        ]
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

      it 'should fail when a string is used on base_paths' do
        expect { AlphaTaxonomy::TaxonRenamer.new(base_paths: '/a,/b').run! }.to raise_error
      end

      it "requests Publishing API to change title and base_path" do
        expect(Services.publishing_api).to receive(:lookup_content_id)
          .with(base_path: "/alpha-taxonomy/awesome-taxon")
          .and_return("awesome-taxon-uuid")

        expect(Services.publishing_api).to receive(:lookup_content_id)
          .with(base_path: "/alpha-taxonomy/4-some-taxon")
          .and_return("4-some-taxon-uuid")

        expect(Services.publishing_api).to receive(:publish)
          .with("awesome-taxon-uuid", "major")

        expect(Services.publishing_api).to receive(:publish)
          .with("4-some-taxon-uuid", "major")

        expect(Services.publishing_api).to receive(:put_content)
          .with("awesome-taxon-uuid", test_payload('Renamed awesome taxon', "/alpha-taxonomy/renamed-awesome-taxon"))

        expect(Services.publishing_api).to receive(:put_content)
          .with("4-some-taxon-uuid", test_payload('Some taxon', "/alpha-taxonomy/some-taxon"))

        AlphaTaxonomy::TaxonRenamer.new(base_paths: base_paths).run!
      end

      it 'should be valid against the taxon schema' do
        valid_uuid = '143ccd35-6951-425a-9ff1-166d127e8f04'

        expect(Services.publishing_api).to receive(:lookup_content_id)
          .with(base_path: "/alpha-taxonomy/awesome-taxon")
          .and_return(valid_uuid)

        expect(Services.publishing_api).to receive(:put_content)
          .with(valid_uuid, be_valid_against_schema('taxon'))
          .once

        expect(Services.publishing_api).to receive(:publish)
          .with(valid_uuid, "major")
          .once

        AlphaTaxonomy::TaxonRenamer.new(base_paths: [base_paths.first]).run!
      end
    end
  end
end
