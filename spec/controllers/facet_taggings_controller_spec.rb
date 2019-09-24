require "rails_helper"

RSpec.describe Facets::FacetTaggingsController do
  describe "find_by_slug" do
    before do
      allow(ContentLookupForm).to receive(:new).and_return(lookup)
      post :find_by_slug, params: {
        facet_group_content_id: "FACET-GROUP-UUID",
        slug: "/foo",
      }
    end

    context "with a valid slug" do
      let(:lookup) { double(:lookup, content_id: "MY-CONTENT-ID", valid?: true) }
      it "redirects to the tagging path" do
        expect(response).to redirect_to(
          facet_group_facet_tagging_path(content_id: "MY-CONTENT-ID"),
        )
      end
    end

    context "with an invalid slug" do
      let(:lookup) { double(:lookup, content_id: "MY-CONTENT-ID", valid?: false) }
      it "returns to the lookup form" do
        expect(response).to be_successful
      end
    end
  end

  describe "show" do
    context "for an existing content item" do
      before do
        allow(ContentItem).to receive(:find!)
        allow(Facets::TaggingUpdateForm).to receive(:from_content_item)

        get :show, params: {
          facet_group_content_id: "FACET-GROUP-UUID",
          content_id: "MY-CONTENT-ID",
        }
      end

      it "responds successfully" do
        expect(response).to be_successful
      end
    end

    context "for a content item which doesn't exist" do
      before do
        allow(ContentItem).to receive(:find!).and_raise(ContentItem::ItemNotFoundError)
        get :show, params: {
          facet_group_content_id: "FACET-GROUP-UUID",
          content_id: "MY-CONTENT-ID",
        }
      end

      it "responds with a 404" do
        expect(response).to be_not_found
      end
    end
  end

  describe "update" do
    let(:content_item) do
      double(:content_item, content_id: "MY-CONTENT-ID")
    end

    before do
      allow(ContentItem).to receive(:find!).and_return(content_item)
      allow(Facets::TaggingUpdatePublisher).to receive(:new).and_return(publisher)
      allow(Facets::TaggingUpdateForm).to receive(:from_content_item)
        .and_return(double(:form, update_attributes_from_form: true))

      put :update, params: {
        facet_group_content_id: "FACET-GROUP-UUID",
        content_id: "MY-CONTENT-ID",
      }
    end

    context "when successful" do
      let(:publisher) { double(:publisher, save_to_publishing_api: true) }

      it "redirects to the tagging path" do
        expect(response).to redirect_to(
          facet_group_facet_tagging_path(
            facet_group_content_id: "FACET-GROUP-UUID",
            content_id: "MY-CONTENT-ID",
          ),
        )
      end
    end

    context "when unsuccessful" do
      let(:publisher) { double(:publisher, save_to_publishing_api: false) }
      before { allow(Facets::TaggingUpdateForm).to receive(:from_content_item) }

      it "responds with an error message in the form" do
        expect(flash[:danger]).to eq("This form contains errors. Please correct them and try again.")
      end
    end

    context "when there is an API conflict" do
      let(:publisher) { double(:publisher, save_to_publishing_api: :conflict) }
      before do
        allow(publisher).to receive(:save_to_publishing_api)
          .and_raise(GdsApi::HTTPConflict)
      end

      it "redirects back to the tagging form" do
        expect(response).to redirect_to(
          facet_group_facet_tagging_path(
            facet_group_content_id: "FACET-GROUP-UUID",
            content_id: "MY-CONTENT-ID",
          ),
        )
      end
    end
  end
end
