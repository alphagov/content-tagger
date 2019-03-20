require "rails_helper"

RSpec.describe Facets::FacetGroupsController do
  let(:facet_groups_service) do
    double(:service, find_all: [{ "content_id" => "xyz-987" }])
  end

  before do
    allow(Facets::RemoteFacetGroupsService).to receive(:new)
      .and_return(facet_groups_service)
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "fetches facet groups from a service" do
      get :index

      expect(facet_groups_service).to have_received(:find_all).once
    end

    it "presents results" do
      expect(Facets::FacetGroupPresenter).to receive(:new)
        .with("content_id" => "xyz-987")

      get :index
    end
  end
end
