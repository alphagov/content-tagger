module BulkTagging
  RSpec.describe FetchRemoteData do
    include GoogleSheetHelper

    describe ".call" do
      let(:url) { tagging_spreadsheet.url }
      let(:tagging_spreadsheet) { create(:tagging_spreadsheet) }

      context "with a valid response" do
        before do
          stub_request(:get, url).to_return(body: google_sheet_fixture, status: 200)
        end

        it "creates tag mappings based on the retrieved data" do
          FetchRemoteData.call(tagging_spreadsheet)

          expect(TagMapping.all.map(&:content_base_path)).to eq(%w[/content-1/ /content-2/])
          expect(TagMapping.all.map(&:link_type)).to eq(%w[taxons taxons])
        end

        it "handles superfluous whitespace when creating tag_mappings" do
          dodgy_spreadsheet_data = empty_google_sheet(
            with_rows: [
              google_sheet_row(
                content_base_path: "/content-1/  ",
                link_title: "  Education",
                link_content_id: "  education-content-id  ",
                link_type: " taxons",
              ),
            ],
          )
          stub_request(:get, url).to_return(body: dodgy_spreadsheet_data, status: 200)

          FetchRemoteData.new(tagging_spreadsheet).call

          tag_mapping = TagMapping.first
          expect(tag_mapping.content_base_path).to eq "/content-1/"
          expect(tag_mapping.link_title).to eq "Education"
          expect(tag_mapping.link_content_id).to eq "education-content-id"
          expect(tag_mapping.link_type).to eq "taxons"
        end
      end

      context "with rows containing the same base path" do
        before do
          row_data = {
            content_base_path: "/content-1/",
            link_title: "Education",
            link_content_id: "education-content-id",
            link_type: "taxons",
          }
          google_sheet_data = empty_google_sheet(
            with_rows: [
              google_sheet_row(**row_data),
              google_sheet_row(**row_data),
            ],
          )

          stub_request(:get, url).to_return(body: google_sheet_data, status: 200)
        end

        it "saves each record per row" do
          FetchRemoteData.call(tagging_spreadsheet)

          expect(TagMapping.count).to eq(2)
          expect(TagMapping.all.map(&:content_base_path)).to eq(%w[/content-1/ /content-1/])
        end
      end

      context "with an invalid response" do
        before do
          stub_request(:get, url).to_return(body: "<html>a long page</html>", status: 400)
        end

        it "does not create any taggings" do
          expect { described_class.call(tagging_spreadsheet) }
            .to_not(change { tagging_spreadsheet.tag_mappings })
        end

        it "returns the error message" do
          expect(described_class.call(tagging_spreadsheet)).to include(
            /there is a problem downloading the spreadsheet/i,
          )
        end

        it "notifies GovukError of the error" do
          expect(GovukError).to receive(:notify)

          described_class.call(tagging_spreadsheet)
        end
      end
    end
  end
end
